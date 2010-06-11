Capistrano::Configuration.instance(:must_exist).load do
  
  def look_for_db_changes
    fetch(:db_changed?, nil) || set(:db_changed?) { check_for_changes('db/migrate') }
  end
  
  def check_for_changes(dir)
    result = capture("cd #{current_release} && git diff-tree `cat #{previous_release}/REVISION` #{branch} -- #{dir} | wc -l").to_i > 0
    puts "Looking for changes in #{dir}... [ #{result ? 'yes' : 'no'} ]"
    result
  end

  define_recipe :automigrate do
    after 'deploy:finalize_update' do
      look_for_db_changes
      after("deploy:symlink_configs", "deploy:migrate") if db_changed?
    end
  end
  
end