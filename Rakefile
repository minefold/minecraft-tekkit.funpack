task :default => :start

$build_dir = File.expand_path("~/funpacks/tekkit/build")
$cache_dir = File.expand_path("~/funpacks/tekkit/cache")
$working_dir = File.expand_path("~/funpacks/tekkit/working")

task :start do
  system %Q{
    # rm -rf #{$working_dir}
    mkdir -p #{$working_dir}
  }

  File.write "#{$working_dir}/data.json", <<-EOS
    {
      "name": "Woodbury",
      "auth": { "whitelist": [] },
      "settings": {
        "max-players": "22",
        "blacklist": "atnan",
        "gamemode": 2,
        "ops": "whatupdave\\nchrislloyd",
        "seed": "s33d",
        "allow-nether": true,
        "allow-flight": false,
        "spawn-animals": true,
        "spawn-monsters": false,
        "spawn-npcs": false,
        "whitelist": "whatupdave\\nchrislloyd"
      }
    }
  EOS

  Dir.chdir($working_dir) do
    raise "error" unless system "PORT=4032 RAM=638 DATAFILE=#{$working_dir}/data.json #{$build_dir}/bin/run 2>&1"
  end
end

task :compile do
  fail unless system "rm -rf #{$build_dir} && mkdir -p #{$build_dir} #{$cache_dir}"
  fail unless system "bin/compile #{$build_dir} #{$cache_dir} 2>&1"
  Dir.chdir($build_dir) do
    if !system("bundle check")
      fail unless system "bundle install --deployment 2>&1"
    end
  end
end

task :import do
  $import = File.expand_path('bin/import')
  $gemfile = File.expand_path('Gemfile')
  fail unless system "cd #{$working_dir}/.. && BUNDLE_GEMFILE=#{$gemfile} #{$import}"
end
