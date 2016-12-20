var grunt  = require("grunt"),
    dotenv = require("dotenv"),
    path   = require("path");

module.exports = function() {

  dotenv.load();

  grunt.loadNpmTasks("grunt-sass");
  grunt.loadNpmTasks("grunt-contrib-coffee");
  grunt.loadNpmTasks("grunt-contrib-clean");
  grunt.loadNpmTasks("grunt-contrib-jade");
  grunt.loadNpmTasks("grunt-contrib-copy");
  grunt.loadNpmTasks("grunt-contrib-watch");
  grunt.loadNpmTasks("grunt-contrib-uglify");
  grunt.loadNpmTasks("grunt-angular-templates");
  grunt.loadNpmTasks("grunt-contrib-concat");


  function bowerf(p) {
    var bower = path.join(__dirname, "bower_components");
    return path.join(bower, p);
  }

  var vendors = [
    [bowerf("d3/d3.js"),                             bowerf("d3/d3.min.js")],
    [bowerf("analytics/index.js"),                   bowerf("analytics/index.js")],
    [bowerf("angular/angular.js"),                   bowerf("angular/angular.min.js")],
    [bowerf("angular-route/angular-route.js"),       bowerf("angular-route/angular-route.min.js")],
    [bowerf("angular-resource/angular-resource.js"), bowerf("angular-resource/angular-resource.min.js")],
    [bowerf("soundmanager2/script/soundmanager2-jsmin.js")],
    [bowerf("papaparse/papaparse.min.js")]
  ];

  vendors.release = function() {
    var result = [];

    for(let i = 0, c = vendors.length; i < c; i++) {
      result.push(vendors[i][1] || vendors[i][0]);
    }

    return result;
  }


  vendors.debug = function() {
    var result = [];

    for(let i = 0, c = vendors.length; i < c; i++) {
      result.push(vendors[i][0]);
    }

    return result;
  };

  var package_info = grunt.file.readJSON("package.json"),
      package_banner = [
        "/*!", 
        "<%= pkg.name %>", 
        [
          "v<%= pkg.version %>",
          "<% if(pkg.commit) { %>",
          "-<%= pkg.commit %>", 
          "<% } %>",
        ].join(""),
        "by <%= pkg.author %>", 
        "[<%= pkg.repository.url %>]", 
        "*/"
      ].join(" ")

  if(process.env["TRAVIS_COMMIT"])
    package_info.commit = process.env["TRAVIS_COMMIT"].substr(0, 8);

  grunt.initConfig({

    pkg: package_info,

    clean: {
      all: [
        "obj", 
        "public/js", 
        "public/css", 
        "public/index.html",
        "public/app.conf",
      ]
    },

    coffee: {
      src: {
        options: {
          bare: false,
          join: true
        },
        files: {
          "obj/js/app.js": [
            "src/coffee/app.coffee", 
            "src/coffee/**/*.coffee"
          ]
        }
      }
    },

    jade: {
      debug: {
        options: {
          data: {
            debug: true
          }
        },
        files: [{
          src: "**/*.jade",
          dest: "obj/html",
          expand: true,
          ext: ".html",
          cwd: "src/jade"
        }]
      },
      release: {
        options: {
          data: {
            debug: false
          }
        },
        files: {
          "public/index.html": "src/jade/index.jade"
        }
      }
    },

    ngtemplates: {
      build: {
        src: ["obj/html/directives/*.html", "obj/html/views/*.html"],
        dest: "obj/js/templates.js",
        options: {
          module: "mh",
          url: function(url) { 
            return url.replace(/^obj\/html\/(.*)\/(.*)\.html$/,"$1.$2");
          }
        }
      }
    },

    concat: {
      options: {
        separator: "; \n"
      },
      dist: {
        src: [
          "obj/js/app.js",
          "obj/js/templates.js",
          "obj/js/soundcloud.js",
          "obj/js/google.js"
        ],
        dest: "public/js/dist.js"
      },
      vendor: {
        src: vendors.debug(),
        dest: "public/js/vendor.js"
      },
      release: {
        options: {
          banner: package_banner
        },
        src: vendors.release().concat([
          "public/js/dist.min.js"
        ]),
        dest: "public/js/app.min.js"
      }
    },

    copy: {
      ionicons: {
        expand: true,
        cwd: "bower_components/ionicons",
        src: ["css/*", "fonts/*"],
        dest: "public/vendor/ionicons"
      },
      zocial: {
        expand: true,
        cwd: "bower_components/zocial/css",
        src: "*",
        dest: "public/vendor/zocial"
      },
      svg: {
        expand: true,
        cwd: "src/svg",
        src: "**/*.svg",
        dest: "public/svg"
      },
      index: {
        files: [{
          expand: true,
          cwd: "obj/html",
          src: "index.html",
          dest: "public/"
        }]
      }
    },

    watch: {
      svg: {
        files: ["src/svg/*.svg"],
        tasks: ["copy:svg"]
      },
      scripts: {
        files: ["src/coffee/**/*.coffee"],
        tasks: ["coffee", "concat:dist"]
      },
      templates: {
        files: ["src/jade/**/*.jade"],
        tasks: ["jade:debug", "copy:index", "ngtemplates", "concat:dist"]
      },
      sass: {
        files: ["src/sass/**/*.sass"],
        tasks: ["sass"]
      }
    },

    sass: {
      build: {
        options: {
          includePaths: require("node-neat").includePaths
        },
        files: {
          "public/css/app.css": "src/sass/app.sass"
        }
      }
    },

    uglify: {
      release: {
        options: {
          banner: package_banner,
          wrap: true
        },
        files: {
          "public/js/dist.min.js": ["public/js/dist.js"]
        }
      }
    }

  });
  
  grunt.registerTask("js", ["coffee", "jade:debug", "ngtemplates", "concat:vendor", "concat:dist"]);
  grunt.registerTask("css", ["sass"]);
  grunt.registerTask("default", ["clean", "css", "js", "copy"]);
  grunt.registerTask("release", ["clean", "default", "jade:release", "uglify", "concat:release"]);

};
