module Reviewit
  class Push < Action

    def run
      run_linter! if options[:linter]
      read_commit_header
      read_commit_diff
      process_commit_message!

      if updating?
        puts 'Updating merge request...'
        description = (options[:message] or read_user_single_line_message('Type a single line description of the change: '))
        url = api.update_merge_request(@mr_id, @subject, @commit_message, @commit_diff, description, options[:branch], linter_ok?)
        puts "Merge Request updated at #{url}"
      else
        abort 'You need to specify the target branch before creating a merge request.' if options[:branch].nil?
        puts "Creating merge request..."
        mr = api.create_merge_request(@subject, @commit_message, @commit_diff, options[:branch], linter_ok?)
        puts "Merge Request created at #{mr[:url]}"
        append_mr_id_to_commit(mr[:id])
      end
    end

  private

    def parse_options
      options = Trollop::options do
        opt :message, 'A message to the given action', type: String
        opt :linter, 'Run linter', default: true
      end
      options[:branch] = ARGV.shift
      options
    end

    def read_commit_diff
      patch = `git show --format="%n"`
      # git 2.1.x returns full patch on git show --format="", so we use %n and remove the lines
      @commit_diff = patch.lines[3..-1].join
    end

    def append_mr_id_to_commit mr_id
      open('|git commit --amend -F -', 'w+') do |git|
        git.write @commit_message
        git.write "\n\n#{MR_STAMP} #{mr_id}\n"
        git.close
      end
    end

    def updating?
      not @mr_id.nil?
    end

    def linter_ok?
      @linter_ok ||= false
    end

    def changed_files
      matches = `git show --format=short`.scan(/^--- (.*)\n\+\+\+ (.*)$/)
      matches.select! do |pair|
        pair[1] != '/dev/null'
      end
      matches.map do |pair|
        pair[1][2..-1]
      end
    end

    def run_linter!
      if linter.empty?
        puts 'No linter configured.'
        return
      end

      changed_files_regex = /\#{changed_files(?:\|(.*))?}/
      linter_command = ''
      if changed_files_regex =~ linter
        glob = $1

        raise 'Your working copy is dirty, use git stash and try again.' unless `git status --porcelain`.empty?
        selected_files = changed_files
        if not glob.nil?
          glob = glob.split(',').map(&:strip)
          selected_files.select! do |file|
            glob.any? do |glob|
              File.fnmatch? glob, file
            end
          end
        end

        if selected_files.empty?
          puts 'No files to lint'
          return true
        end

        linter_command = linter.gsub(changed_files_regex, selected_files.join(' '))
      else
        linter_command = "git show | #{linter}"
      end
      puts linter_command
      @linter_ok = system(linter_command)
      raise 'Lint error' unless @linter_ok
    end
  end
end
