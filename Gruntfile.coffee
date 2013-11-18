module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    handlebars:
      compile:
        options:
          namespace: 'JST'

          processName: (name) ->
            name = name.replace('build/public/js/templates/', '')
            name = name.replace('.hbs', '')

            return name

        files:
          'build/public/js/templates.js': ['build/public/js/templates/**/*.hbs']

    clean:
      build:
        src: "build"

      cleanup:
        src: ["build/public/js", "build/public/.tmp/js/coffeescript.js"]

      deleteTmp:
        src: ["build/public/.tmp"]

    copy:
      build:
        cwd: 'app'
        src: ['**']
        dest: 'build'
        expand: true

      compiled:
        cwd: 'build/public/'
        src: '.tmp/js/**.js'
        dest: 'build/public/js/'
        expand: true
        flatten: true
        filter: 'isFile'

    coffee:
      compile:
        files:
          'build/public/.tmp/js/coffeescript.js': ['build/public/js/**/*.coffee']

    concat:
      options:
        separator: ';'

      dist:
        src: ['build/public/.tmp/js/**/*.js', 'build/public/js/**/*.js']
        dest: 'build/public/.tmp/js/<%= pkg.name %>.js'

    uglify:
      options:
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'

      dist:
        files:
          'build/public/.tmp/js/<%= pkg.name %>.min.js': ['<%= concat.dist.dest %>']

    watch:
      scripts:
        files: ['app/**/*'],
        tasks: ['default']

      server:
        files: ['!app/**/*', 'src/**/*', 'app.coffee']
        tasks: ['express:dev']
        options:
          nospawn: true

    express:
      dev:
        options:
          cmd: 'coffee'
          script: 'app.coffee'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-express-server'
  grunt.loadNpmTasks 'grunt-contrib-handlebars'

  grunt.registerTask 'default', ['clean:build', 'copy', 'coffee', 'handlebars', 'concat', 'uglify', 'clean:cleanup', 'copy:compiled', 'clean:deleteTmp']
  grunt.registerTask 'server', ['express:dev', 'watch:server']