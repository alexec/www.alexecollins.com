i=3
pop=['tutorial-hibernate-jpa-spring-mvc-part-2',
      'tutorial-hibernate-jpa-part-1',
      'tutorial-junit-rule',
      '5-tips-unit-testing-threaded-code',
      'tutorial-integration-testing-selenium-part-1',
      'tutorial-integration-testing-selenium-part-2',
      'team-dashboard-dashing',
      'dagger-di-spring-refuges-10-tips',
      '5-minute-easyb-bdd-tutorial',
      'tomcat-context-junit-rule',
      'jmeter-custom-sampler-template',
      'git-tips-git-xpush',
      'tips-robust-bash-scripts',
      'applet-model-view-controller',
      'thread-jiggling']
map={}
File.open('content.1.csv').each(sep='™') do |l|
    s=l.split('€')
    tm=Time.at(s[0].to_i)
    tt=s[1].gsub(/"/, '')
    cn=s[2].chomp('™')

puts tt
path1=tt.downcase.gsub(/ (a|an,and|as|at|before|but|by|for|from|is|in|into|like|of|off|on|onto|per|since|than|the|this|that|to|up|via|with) /, ' ').gsub(/[^a-z0-9]+/, '-').gsub(/-$/, '').gsub(/^-/,'')
    path="#{tm.strftime('%Y-%m-%m')}-#{path1}"
    fn="source/#{path}.html.md"

    puts path1

    if pop.include?(path1)
        puts "popular"
        map[path1] = tt
    end


    File.open(fn, 'w') do |f|
        f.puts '---'
        f.puts "title: \"#{tt}\""
        f.puts '---'
        code=false
        cn.each_line do |l|
            if l.include?('<code')
                code=true
            elsif l.include?('</code')
                code=false
            else
                f.puts "#{code ? "\t" : ''}#{l.gsub(/"\?q=/,'"/').gsub(/\?q=/,'').gsub(/http:..www.alexecollins.com/, '')}"
            end
        end
     end
end

File.open('source/404.html.md', 'w') do |f|
    f.puts '---'
    f.puts 'title: 404'
    f.puts '---'
    f.puts "Ops! Can\'t find what you\'re looking for, but it\'s probably one of these popular pages:"
    f.puts ''
    pop.each do |p|
        f.puts("* [#{map[p]}](/content/#{p})")
    end
end

# exec "file source/201*.html|grep -v HTML|sed 's/:.*//'|while read F ; do mv -v $F $(echo $F | sed 's/html.html/html.md/') ; done"