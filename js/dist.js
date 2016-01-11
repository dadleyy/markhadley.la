var mh,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

mh = (function() {
  var failed_config, http, injector, loaded_config;
  mh = angular.module('mh', ['ngRoute', 'ngResource']);
  loaded_config = function(response) {
    var client_id, data;
    data = response.data;
    mh.value('CONFIG', data);
    mh.value('URLS', data.urls);
    mh.value('GOOGLE', data.google);
    mh.value('BACKGROUND', data.background);
    if (data.soundcloud && data.soundcloud.client_id) {
      client_id = atob(data.soundcloud.client_id);
      mh.value('SOUNDCLOUD_KEY', client_id);
      mh.value('SOUNDCLOUD_USER', data.soundcloud.user_id);
    }
    return angular.bootstrap(document, ['mh']);
  };
  failed_config = function() {};
  injector = angular.injector(['ng']);
  http = injector.get('$http');
  http.get('/app.conf').then(loaded_config, failed_config);
  return mh;
})();

mh.config([
  '$locationProvider', function($locationProvider) {
    return $locationProvider.html5Mode(true);
  }
]);

(function(_this) {
  return (function() {
    var HomeController;
    HomeController = function($scope, playlists, about_page, colors) {
      var featured, is_featured, pl, tags, _i, _len;
      featured = [];
      for (_i = 0, _len = playlists.length; _i < _len; _i++) {
        pl = playlists[_i];
        tags = pl.tag_list;
        is_featured = /featured/i.test(tags);
        if (is_featured) {
          featured.push(pl);
        }
      }
      $scope.playlists = featured;
      $scope.about_page = about_page;
      return $scope.colors = colors;
    };
    HomeController.$inject = ['$scope', 'playlists', 'about_page', 'colors'];
    return mh.controller('HomeController', HomeController);
  });
})(this)();

mh.directive('mhBackground', [
  'BACKGROUND', function(BACKGROUND) {
    var mhBackground;
    return mhBackground = {
      replace: true,
      templateUrl: 'directives.background',
      scope: {},
      link: function($scope, $element, $attrs) {
        var url_style;
        url_style = ['url(', BACKGROUND, ')'].join('');
        return $element.css("background-image", url_style);
      }
    };
  }
]);

mh.directive('mhBio', [
  '$sce', function($sce) {
    var mhBio;
    return mhBio = {
      replace: true,
      templateUrl: 'directives.bio',
      scope: {
        page: '='
      },
      link: function($scope, $element, $attrs) {
        return $scope.safe = function() {
          return $sce.trustAsHtml($scope.page.content);
        };
      }
    };
  }
]);

mh.directive('mhDiscography', [
  '$timeout', 'Viewport', 'Audio', function($timeout, Viewport, Audio) {
    var mDiscography;
    return mDiscography = {
      replace: true,
      templateUrl: 'directives.discography',
      scope: {
        colors: '=',
        playlists: '='
      },
      link: function($scope, $element, $attrs) {
        var init;
        $scope.active_index = 0;
        $scope.nav = function(inc) {
          var right_bound;
          right_bound = $scope.playlists.length - 1;
          $scope.active_index += inc;
          Audio.stop();
          if ($scope.active_index < 0) {
            $scope.active_index = 0;
          }
          if ($scope.active_index > right_bound) {
            $scope.active_index = right_bound;
          }
          return $scope.$broadcast('playlist_change', $scope.active_index);
        };
        init = function() {
          return $scope.$broadcast('playlist_change', 0);
        };
        return $timeout(init);
      }
    };
  }
]);

mh.directive('mhFooter', [
  '$rootScope', function($rootScope) {
    var mhFooter;
    return mhFooter = {
      replace: true,
      templateUrl: 'directives.footer',
      scope: {},
      link: function($scope, $element, $attrs) {
        var update;
        $scope.active = false;
        update = function(evt, route_info) {
          var route;
          route = route_info.$$route;
          if (route) {
            return $scope.active = route.name;
          }
        };
        return $rootScope.$on('$routeChangeStart', update);
      }
    };
  }
]);

mh.directive('mhHeader', [
  'Loop', function(Loop) {
    var SPEED, body, getMaxTop, getTop, html, mhHeader;
    SPEED = 20;
    getTop = function() {
      if (window.pageYOffset) {
        return window.pageYOffset;
      } else {
        return document.documentElement.scrollTop;
      }
    };
    body = document.body;
    html = document.documentElement;
    getMaxTop = function() {
      var height, vals;
      vals = [body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight];
      height = Math.max.apply(null, vals);
      return height - window.innerHeight;
    };
    return mhHeader = {
      replace: true,
      templateUrl: 'directives.header',
      scope: {},
      link: function($scope, $element, $attrs) {
        var direction, loop_id, update;
        loop_id = null;
        direction = 0;
        update = function() {
          var max_top, next, top;
          top = getTop();
          max_top = getMaxTop();
          direction *= 1.05;
          next = top + direction;
          scrollTo(0, next);
          if (next > max_top) {
            return Loop.remove(loop_id);
          } else if (next < 0) {
            return Loop.remove(loop_id);
          }
        };
        return $scope.scroll = function() {
          var above_half;
          above_half = getTop() < (getMaxTop() * 0.5);
          direction = above_half ? SPEED : -SPEED;
          return loop_id = Loop.add(update);
        };
      }
    };
  }
]);

mh.directive('mhPageTitle', [
  '$rootScope', 'Analytics', function($rootScope, Analytics) {
    var default_title, mhPageTitle;
    default_title = 'Composer';
    return mhPageTitle = {
      scope: {},
      link: function($scope, $element, $attrs) {
        var error, start, update;
        update = function(evt, route_event) {
          var route, route_title, title;
          route = route_event.$$route;
          route_title = route && route.title ? route.title : default_title;
          title = ['Mark Hadley', route_title].join(' | ');
          $element.html(title);
          return Analytics.track(route.originalPath, route.title);
        };
        start = function(evt, route_event) {
          var route;
          route = route_event.$$route;
          if (route) {
            return Analytics.event('routing', 'route_start', route.originalPath);
          }
        };
        error = function(evt, route_event) {
          var route;
          route = route_event.$$route;
          if (route) {
            return Analytics.event('routing', 'route_error', route.originalPath);
          }
        };
        $rootScope.$on('$routeChangeStart', start);
        $rootScope.$on('#routeChangeError', error);
        return $rootScope.$on('$routeChangeSuccess', update);
      }
    };
  }
]);

mh.directive('mhPlayer', [
  'Audio', function(Audio) {
    var mhPlayer;
    return mhPlayer = {
      replace: true,
      templateUrl: 'directives.player',
      require: '^mhPlaylist',
      scope: {
        track: '='
      },
      link: function($scope, $element, $attrs, playlist_controller) {
        $scope.close = function() {
          return playlist_controller.close();
        };
        $scope.stop = function() {
          return $scope.track.pause();
        };
        $scope.play = function() {
          return $scope.track.play();
        };
        $scope.next = function() {
          return playlist_controller.playNext();
        };
        $scope.back = function() {
          return playlist_controller.playPrevious();
        };
        return $scope.playing = function() {
          return $scope.track.isPlaying();
        };
      }
    };
  }
]);

mh.directive('mhPlaylist', [
  'Viewport', 'Loop', 'Audio', 'Drawing', function(Viewport, Loop, Audio, Drawing) {
    var PlaylistController, SPIN_SPEED, getColor, mhPlaylist, nav, randspeed, tof, toi;
    tof = function(num) {
      return parseFloat(num);
    };
    toi = function(num) {
      return parseInt(num);
    };
    SPIN_SPEED = 0.2;
    randspeed = function(indx) {
      var large;
      large = ((Math.random() * 100) % 0.5) + 0.1;
      if (indx % 2 === 0) {
        return large;
      } else {
        return -large;
      }
    };
    getColor = function(track, indx) {
      var cleansed, color_list, color_options, colors, found_color, fount_color, list_id, playlist_id, _i, _len;
      colors = this.scope.colors;
      playlist_id = this.playlist.id;
      for (_i = 0, _len = colors.length; _i < _len; _i++) {
        color_list = colors[_i];
        list_id = toi(color_list.id);
        if (list_id === track.id) {
          fount_color = color_list.color;
        } else if (list_id === playlist_id) {
          color_options = color_list.color.split(',');
          found_color = color_options[indx % color_options.length];
        }
      }
      cleansed = (found_color || '#fff').replace(/\s/g, '');
      return ['#', cleansed].join('');
    };
    nav = function(dir) {
      var next;
      next = this.active_index + dir;
      if (next > this.tracks.length - 1) {
        next = 0;
      } else if (next < 0) {
        next = this.tracks.length - 1;
      }
      return this.tracks[next].play();
    };
    PlaylistController = (function() {
      function PlaylistController($scope, $element) {
        this.scope = $scope;
        this.rings = [];
        this.tracks = [];
        this.rotation_offsets = [];
        this.svg = d3.select($element[0]).append('svg');
        this.ring_container = this.svg.append('g');
        this.playback_ring = this.ring_container.append('path');
        this.arc = Drawing.arcFactory($scope);
        this.width = 100;
        this.height = 100;
        this.playlist = this.scope.playlist;
        this.active_index = -1;
        this.playlist_rotation = 0;
        this.playback_ring.attr({
          'fill': 'white'
        });
      }

      PlaylistController.prototype.playNext = function() {
        return nav.call(this, 1);
      };

      PlaylistController.prototype.playPrevious = function() {
        return nav.call(this, -1);
      };

      PlaylistController.prototype.draw = function() {
        var indx, offset, ring, rotation, track_instance, _i, _len, _ref, _results;
        this.playlist_rotation += SPIN_SPEED;
        if (this.active_index >= 0) {
          track_instance = this.tracks[this.active_index];
          this.playback_ring.attr({
            'd': this.arc.playback(track_instance)
          });
        }
        _ref = this.rings;
        _results = [];
        for (indx = _i = 0, _len = _ref.length; _i < _len; indx = ++_i) {
          ring = _ref[indx];
          offset = this.rotation_offsets[indx];
          if (this.scope.active) {
            _results.push(ring.rotate(this.playlist_rotation));
          } else {
            rotation = indx % 2 === 0 ? -this.playlist_rotation : this.playlist_rotation;
            _results.push(ring.rotate(offset + rotation));
          }
        }
        return _results;
      };

      PlaylistController.prototype.resize = function(width, height) {
        this.width = width;
        this.height = height;
        this.svg.attr({
          width: this.width,
          height: this.height
        });
        this.center();
        return this.draw();
      };

      PlaylistController.prototype.center = function() {
        var height, left, top, width;
        width = this.width;
        height = this.height;
        top = this.scope.active ? 120 : height * 0.5;
        left = width * 0.5;
        return this.ring_container.attr({
          transform: 'translate(' + left + ',' + top + ')'
        });
      };

      PlaylistController.prototype.open = function() {
        var active_track, fill_color, indx, instance, opacity, r, _i, _len, _ref, _results;
        this.center();
        active_track = this.tracks[this.active_index];
        fill_color = getColor.call(this, active_track, this.active_index);
        this.playback_ring.attr({
          'opacity': '1.0',
          'fill': fill_color
        });
        _ref = this.rings;
        _results = [];
        for (indx = _i = 0, _len = _ref.length; _i < _len; indx = ++_i) {
          r = _ref[indx];
          instance = this.tracks[indx];
          opacity = instance.playing ? '1.0' : '0.5';
          r.path.transition().duration(400).ease('elastic').attr({
            'opacity': opacity,
            'd': this.arc.fn(instance, indx)
          });
          _results.push(r.speed = 0.2);
        }
        return _results;
      };

      PlaylistController.prototype.close = function() {
        var indx, instance, r, _i, _len, _ref;
        if (this.scope.active) {
          this.scope.active.stop();
        }
        this.scope.active = null;
        this.active_index = -1;
        this.playback_ring.attr({
          'opacity': '0.0'
        });
        this.center();
        _ref = this.rings;
        for (indx = _i = 0, _len = _ref.length; _i < _len; indx = ++_i) {
          r = _ref[indx];
          instance = this.tracks[indx];
          r.path.transition().duration(400).ease('elastic').attr({
            'opacity': '1.0',
            'd': this.arc.fn(instance, indx)
          });
          r.speed = randspeed(indx);
        }
        try {
          return this.scope.$digest();
        } catch (_error) {
          return false;
        }
      };

      PlaylistController.prototype.addTrack = function(track) {
        var arc_fn, clickfn, fill_color, group, indx, instance, mouseout, mouseover, path, ring, started, stopped, was_clicked;
        indx = this.tracks.length;
        was_clicked = false;
        group = this.ring_container.append('g');
        path = group.append('path');
        fill_color = getColor.call(this, track, indx);
        group.attr('data-track', track.title);
        instance = new Audio.Track(track);
        arc_fn = (function(_this) {
          return function() {
            return _this.arc.fn(instance, indx);
          };
        })(this);
        path.attr({
          'fill': fill_color,
          'd': arc_fn()
        });
        ring = new Drawing.Ring(group, path, arc_fn);
        this.rotation_offsets.push((Math.random() * 1000) % 360);
        clickfn = (function(_this) {
          return function() {
            if (instance.playing) {
              return instance.stop();
            } else {
              was_clicked = true;
              instance.play();
              return was_clicked = false;
            }
          };
        })(this);
        stopped = (function(_this) {
          return function() {
            _this.scope.active = null;
            return _this.close();
          };
        })(this);
        started = (function(_this) {
          return function() {
            _this.scope.active = instance;
            _this.active_index = indx;
            _this.open();
            try {
              _this.scope.$digest();
            } catch (_error) {
              false;
            }
            return _this.scope.$broadcast('playback_start', instance);
          };
        })(this);
        mouseover = (function(_this) {
          return function() {};
        })(this);
        mouseout = (function(_this) {
          return function() {};
        })(this);
        ring.on('click', clickfn).on('mouseover', mouseover).on('mouseout', mouseout);
        instance.on('stop', stopped).on('start', started);
        this.rings.push(ring);
        return this.tracks.push(instance);
      };

      return PlaylistController;

    })();
    PlaylistController.$inject = ['$scope', '$element'];
    return mhPlaylist = {
      replace: true,
      templateUrl: 'directives.playlist',
      controller: PlaylistController,
      scope: {
        playlist: '=',
        index: '=',
        colors: '='
      },
      link: function($scope, $element, $attrs, playlist_controller) {
        var loop_id, resize, spin, startSpin, stopSpin, toggle, track, _i, _len, _ref;
        $scope.active = null;
        loop_id = null;
        resize = function() {
          var height, width;
          width = $element[0].offsetWidth;
          height = $element[0].offsetHeight;
          return playlist_controller.resize(width, height);
        };
        spin = function() {
          return playlist_controller.draw();
        };
        stopSpin = function() {
          if (loop_id) {
            Loop.remove(loop_id);
          }
          return loop_id = null;
        };
        startSpin = function() {
          return loop_id = Loop.add(spin);
        };
        toggle = function(evt, active_index) {
          if (active_index === $scope.index) {
            return startSpin();
          } else {
            return stopSpin();
          }
        };
        Viewport.addListener(resize);
        _ref = $scope.playlist.tracks;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          track = _ref[_i];
          playlist_controller.addTrack(track);
        }
        resize();
        return $scope.$on('playlist_change', toggle);
      }
    };
  }
]);

mh.directive('mhWaveform', [
  '$http', 'Viewport', 'Waveform', function($http, Viewport, Waveform) {
    var mhWaveform;
    return mhWaveform = {
      replace: true,
      templateUrl: 'directives.waveform',
      scope: {
        track: '='
      },
      link: function($scope, $element, $attrs) {
        var canvas, context, height, receive, resize, start, waveform, waveform_data, width;
        canvas = document.createElement('canvas');
        context = canvas.getContext('2d');
        waveform_data = null;
        waveform = new Waveform({
          canvas: canvas,
          innerColor: '#414141'
        });
        width = 0;
        height = 0;
        receive = function(response) {
          var received_data;
          received_data = response.data;
          waveform.width = width;
          waveform.height = height;
          return waveform.update({
            data: received_data
          });
        };
        start = function(evt, track) {
          var data_request, waveform_url;
          waveform_data = null;
          waveform_url = track.waveform();
          data_request = $http.get("/api/waveform", {
            params: {
              url: waveform_url
            }
          });
          return data_request.then(receive);
        };
        resize = function() {
          width = $element[0].offsetWidth;
          height = $element[0].offsetHeight;
          waveform.width = width;
          waveform.height = height;
          canvas.width = width;
          canvas.height = height;
          return waveform.redraw();
        };
        Viewport.addListener(resize);
        $scope.$on('playback_start', start);
        return $element.append(canvas);
      }
    };
  }
]);

mh.config([
  '$routeProvider', function($routeProvider) {
    return $routeProvider.otherwise({
      redirectTo: '/'
    });
  }
]);

mh.config([
  '$routeProvider', function($routeProvider) {
    var api_home;
    api_home = "https://api.soundcloud.com";
    return $routeProvider.when('/', {
      templateUrl: 'views.home',
      controller: 'HomeController',
      name: 'home',
      resolve: {
        playlists: [
          '$q', '$http', 'SOUNDCLOUD_KEY', 'SOUNDCLOUD_USER', function($q, $http, SOUNDCLOUD_KEY, SOUNDCLOUD_USER) {
            var defferred, fail, finish, http_promise, query_parms, uri_path;
            defferred = $q.defer();
            uri_path = [api_home, 'users', SOUNDCLOUD_USER, 'playlists.json'].join('/');
            query_parms = ['client_id', SOUNDCLOUD_KEY].join('=');
            finish = function(response) {
              var playlists;
              playlists = response.data;
              return defferred.resolve(playlists);
            };
            fail = function() {};
            http_promise = $http.get([uri_path, query_parms].join('?'));
            http_promise.then(finish, fail);
            return defferred.promise;
          }
        ],
        about_page: [
          '$q', '$http', 'URLS', function($q, $http, URLS) {
            var content_params, content_request, content_url, defferred, receive;
            defferred = $q.defer();
            content_url = [URLS.blog, 'pages'].join('/');
            content_params = ['filter[name]', 'about'].join('=');
            content_request = $http.get([content_url, content_params].join('?'));
            receive = function(response) {
              return defferred.resolve(response.data[0]);
            };
            content_request.then(receive);
            return defferred.promise;
          }
        ],
        colors: [
          '$q', '$http', 'CONFIG', function($q, $http, CONFIG) {
            var colors_request, colors_url, defferred, receive;
            defferred = $q.defer();
            colors_url = CONFIG.colors_sheet;
            colors_request = $http.get(colors_url);
            receive = function(response) {
              var parsed;
              parsed = Papa.parse(response.data, {
                header: true
              });
              return defferred.resolve(parsed.data);
            };
            colors_request.then(receive);
            return defferred.promise;
          }
        ]
      }
    });
  }
]);

mh.service('Analytics', [
  'GOOGLE', function(GOOGLE) {
    var Analytics;
    ga('create', GOOGLE.tracking, 'auto');
    ga('send', 'pageview');
    Analytics = {
      track: function(path, title) {
        return ga('send', 'pageview', {
          page: path,
          title: title
        });
      },
      log: function() {},
      event: function(category, action, data) {
        return ga('send', 'event', category, action, data);
      }
    };
    return Analytics;
  }
]);

mh.service('Audio', [
  '$q', 'Analytics', 'Loop', 'SOUNDCLOUD_KEY', function($q, Analytics, Loop, SOUNDCLOUD_KEY) {
    var Audio, Track, active_track, trigger;
    active_track = null;
    soundManager.setup({
      debugMode: false
    });
    trigger = function(evt) {
      var fn, _i, _len, _ref, _results;
      _ref = this.listeners[evt];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        fn = _ref[_i];
        _results.push(fn());
      }
      return _results;
    };
    Track = (function() {
      function Track(track) {
        var client_params;
        this.track = track;
        client_params = ['client_id', SOUNDCLOUD_KEY].join('=');
        this.id = this.track.id;
        this.playing = false;
        this.playback_loop = null;
        this.listeners = {
          start: [],
          stop: [],
          playback: [],
          pause: []
        };
        this.sound = soundManager.createSound({
          url: [this.track.stream_url, client_params].join('?')
        });
      }

      Track.prototype.position = function() {
        return this.sound.position;
      };

      Track.prototype.duration = function() {
        return this.track.duration;
      };

      Track.prototype.title = function() {
        return this.track.title;
      };

      Track.prototype.waveform = function() {
        return this.track.waveform_url;
      };

      Track.prototype.isPlaying = function() {
        return this.playing;
      };

      Track.prototype.pause = function() {
        this.playing = false;
        active_track = null;
        trigger.call(this, 'pause');
        return this.sound.stop();
      };

      Track.prototype.play = function() {
        var update;
        this.playing = true;
        update = (function(_this) {
          return function() {
            return trigger.call(_this, 'playback');
          };
        })(this);
        if (active_track && active_track.id !== this.id) {
          active_track.stop();
        }
        active_track = this;
        this.playback_loop = Loop.add(update);
        trigger.call(this, 'start');
        Analytics.event('audio', 'playback:start', this.track.title);
        return this.sound.play();
      };

      Track.prototype.stop = function() {
        this.playing = false;
        Loop.remove(this.playback_loop);
        trigger.call(this, 'stop');
        return this.sound.stop();
      };

      Track.prototype.on = function(evt, fn) {
        if (this.listeners[evt] && angular.isFunction(fn)) {
          this.listeners[evt].push(fn);
        }
        return this;
      };

      return Track;

    })();
    Audio = {
      stop: function() {
        if (active_track) {
          return active_track.stop();
        }
      }
    };
    Audio.Track = Track;
    return Audio;
  }
]);

mh.service('Drawing', [
  function() {
    var Drawing, Ring, arc_inc, arc_spacing, arc_width, start_radius, tof;
    arc_width = 15;
    arc_spacing = 2;
    arc_inc = arc_width + arc_spacing;
    start_radius = 60;
    tof = function(num) {
      return parseFloat(num);
    };
    Ring = (function() {
      function Ring(group, path, arc_fn) {
        var click, out, over, trigger;
        this.group = group;
        this.path = path;
        this.arc_fn = arc_fn;
        this.position = {
          x: 0,
          y: 0
        };
        this.rotation = (Math.random() * 1000) % 360;
        this.stopped = false;
        this.listeners = {
          click: [],
          mouseout: [],
          mouseover: []
        };
        trigger = (function(_this) {
          return function(evt) {
            var fn, _i, _len, _ref, _results;
            _ref = _this.listeners[evt];
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              fn = _ref[_i];
              _results.push(fn());
            }
            return _results;
          };
        })(this);
        over = (function(_this) {
          return function() {
            _this.stopped = true;
            _this.scale = 1.2;
            return trigger('mouseover');
          };
        })(this);
        out = (function(_this) {
          return function() {
            _this.stopped = false;
            _this.scale = 1.0;
            return trigger('mouseout');
          };
        })(this);
        click = (function(_this) {
          return function() {
            return trigger('click');
          };
        })(this);
        this.group.on('mouseover', over).on('mouseout', out).on('click', click);
      }

      Ring.prototype.rotate = function(degrees) {
        var rotate;
        this.rotation = degrees;
        rotate = ['rotate(', this.rotation, ')'].join('');
        return this.path.attr({
          'transform': rotate
        });
      };

      Ring.prototype.update = function() {};

      Ring.prototype.on = function(evt, fn) {
        if (this.listeners[evt] && angular.isFunction(fn)) {
          this.listeners[evt].push(fn);
        }
        return this;
      };

      return Ring;

    })();
    return Drawing = {
      Ring: Ring,
      arcFactory: function($scope) {
        var arc_gen, calc, end, find, hover_indx, inner, outer, playlist, radians, start, total_duration, track, _i, _len, _ref;
        playlist = $scope.playlist;
        arc_gen = {};
        total_duration = 0;
        _ref = playlist.tracks;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          track = _ref[_i];
          total_duration += tof(track.duration);
        }
        hover_indx = -1;
        radians = function(track) {
          var duration, percent, rads;
          duration = track.duration;
          percent = tof(duration) / total_duration;
          return rads = (360 * percent) * (Math.PI / 180);
        };
        find = function(target) {
          var found, index, _j, _len1, _ref1;
          found = -1;
          _ref1 = playlist.tracks;
          for (index = _j = 0, _len1 = _ref1.length; _j < _len1; index = ++_j) {
            track = _ref1[index];
            if (track.id === target.id) {
              found = index;
            }
          }
          return found;
        };
        inner = function(track) {
          var indx, inner_radius, play_inner;
          if ($scope.active) {
            play_inner = 80;
            return play_inner;
          } else {
            indx = find(track);
            return inner_radius = start_radius + (indx * arc_inc);
          }
        };
        outer = function(track) {
          var indx, inner_radius, outer_radius, play_outer;
          if ($scope.active) {
            play_outer = 95;
            return play_outer;
          } else {
            indx = find(track);
            inner_radius = start_radius + (indx * arc_inc);
            return outer_radius = inner_radius + arc_width;
          }
        };
        end = function(track, indx) {
          var angle_width, end_angle, start_angle;
          end_angle = 0;
          if ($scope.active) {
            start_angle = start(track, indx);
            angle_width = radians(track.track);
            end_angle = start_angle + angle_width;
          } else {
            end_angle = radians(track.track);
          }
          return end_angle;
        };
        start = function(track, indx) {
          var prev_start, prev_track, prev_width, start_angle;
          start_angle = 0;
          if ($scope.active && indx > 0) {
            prev_track = playlist.tracks[indx - 1];
            prev_start = start(prev_track, indx - 1);
            prev_width = radians(prev_track);
            start_angle = prev_start + prev_width;
          }
          return start_angle;
        };
        calc = function(track, played) {
          var duration, percent, rads;
          duration = track.duration();
          percent = tof(played) / tof(duration);
          return rads = (360 * percent) * (Math.PI / 180);
        };
        arc_gen.fn = d3.svg.arc().startAngle(start).endAngle(end).innerRadius(inner).outerRadius(outer);
        arc_gen.playback = d3.svg.arc().startAngle(function() {
          return 0;
        }).endAngle(function(active_track) {
          var duration, percent, position;
          duration = active_track.duration();
          position = active_track.position();
          percent = position / duration;
          return (360 * percent) * (Math.PI / 180);
        }).innerRadius(function() {
          return 75;
        }).outerRadius(function() {
          return 60;
        });
        return arc_gen;
      }
    };
  }
]);

mh.service('Loop', [
  '$window', function($window) {
    var Loop, active_listeners, fn_name, luid, request, run, running, vendor, vendors, _i, _len;
    luid = (function() {
      var id;
      id = 0;
      return function() {
        id += 1;
        return id;
      };
    })();
    active_listeners = [];
    running = false;
    vendors = ['', 'ms', 'moz', 'webkit', 'o'];
    request = function(fn) {
      return $window.setTimeout(fn, 33);
    };
    for (_i = 0, _len = vendors.length; _i < _len; _i++) {
      vendor = vendors[_i];
      fn_name = vendor + 'RequestAnimationFrame';
      fn_name = fn_name[0].toLowerCase() + fn_name.substr(1);
      if ($window[fn_name]) {
        request = $window[fn_name];
        break;
      }
    }
    run = function() {
      var wrapper, _j, _len1;
      if (active_listeners.length === 0) {
        running = false;
      } else {
        for (_j = 0, _len1 = active_listeners.length; _j < _len1; _j++) {
          wrapper = active_listeners[_j];
          wrapper();
        }
      }
      if (running) {
        return request(run);
      }
    };
    return Loop = {
      add: function(fn) {
        var wrapper;
        wrapper = function() {
          return fn();
        };
        wrapper.uid = luid();
        active_listeners.push(wrapper);
        if (!running) {
          running = true;
          run();
        }
        return wrapper.uid;
      },
      remove: function(id) {
        var indx, wrapper, _j, _len1, _results;
        _results = [];
        for (indx = _j = 0, _len1 = active_listeners.length; _j < _len1; indx = ++_j) {
          wrapper = active_listeners[indx];
          if (wrapper.uid === id) {
            active_listeners.splice(indx, 1);
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    };
  }
]);

mh.service('Viewport', [
  '$window', '$rootScope', 'Loop', function($window, $rootScope, Loop) {
    var Viewport, listeners, resize_loop_id, stopListening, stop_timeout, update;
    resize_loop_id = null;
    listeners = [];
    stop_timeout = null;
    stopListening = function() {
      Loop.remove(resize_loop_id);
      return resize_loop_id = null;
    };
    $window.onresize = function() {
      if (resize_loop_id === null) {
        resize_loop_id = Loop.add(update);
      }
      $window.clearTimeout(stop_timeout);
      return stop_timeout = $window.setTimeout(stopListening, 1000);
    };
    update = function() {
      var height, listener, width, _i, _len;
      width = $window.innerWidth;
      height = $window.innerHeight;
      for (_i = 0, _len = listeners.length; _i < _len; _i++) {
        listener = listeners[_i];
        listener(width, height);
      }
      return $rootScope.$digest();
    };
    return Viewport = {
      addListener: function(fn) {
        listeners.push(fn);
        return fn($window.innerWidth, $window.innerHeight);
      }
    };
  }
]);

mh.service('Waveform', [
  function() {
    var Waveform;
    Waveform = (function() {
      function Waveform(options) {
        this.redraw = __bind(this.redraw, this);
        this.container = options.container;
        this.canvas = options.canvas;
        this.data = options.data || [];
        this.outerColor = options.outerColor || "transparent";
        this.innerColor = options.innerColor || "#FFFFFF";
        this.interpolate = true;
        if (options.interpolate === false) {
          this.interpolate = false;
        }
        this.patchCanvasForIE(this.canvas);
        this.context = this.canvas.getContext("2d");
      }

      Waveform.prototype.setData = function(data) {
        return this.data = data;
      };

      Waveform.prototype.setDataInterpolated = function(data) {
        return this.setData(this.interpolateArray(data, this.width));
      };

      Waveform.prototype.setDataCropped = function(data) {
        return this.setData(this.expandArray(data, this.width));
      };

      Waveform.prototype.update = function(options) {
        if (options.interpolate != null) {
          this.interpolate = options.interpolate;
        }
        if (this.interpolate === false) {
          this.setDataCropped(options.data);
        } else {
          this.setDataInterpolated(options.data);
        }
        return this.redraw();
      };

      Waveform.prototype.redraw = function() {
        var d, i, middle, t, _i, _len, _ref, _results;
        this.clear();
        this.context.fillStyle = this.innerColor;
        middle = this.height / 2;
        i = 0;
        _ref = this.data;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          d = _ref[_i];
          t = this.width / this.data.length;
          this.context.clearRect(t * i, middle - middle * d, t, middle * d * 2);
          this.context.fillRect(t * i, middle - middle * d, t, middle * d * 2);
          _results.push(i++);
        }
        return _results;
      };

      Waveform.prototype.clear = function() {
        this.context.fillStyle = this.outerColor;
        this.context.clearRect(0, 0, this.width, this.height);
        return this.context.fillRect(0, 0, this.width, this.height);
      };

      Waveform.prototype.patchCanvasForIE = function(canvas) {
        var oldGetContext;
        if (typeof window.G_vmlCanvasManager !== "undefined") {
          canvas = window.G_vmlCanvasManager.initElement(canvas);
          oldGetContext = canvas.getContext;
          return canvas.getContext = function(a) {
            var ctx;
            ctx = oldGetContext.apply(canvas, arguments);
            canvas.getContext = oldGetContext;
            return ctx;
          };
        }
      };

      Waveform.prototype.expandArray = function(data, limit, defaultValue) {
        var i, newData, _i, _ref;
        if (defaultValue == null) {
          defaultValue = 0.0;
        }
        newData = [];
        if (data.length > limit) {
          newData = data.slice(data.length - limit, data.length);
        } else {
          for (i = _i = 0, _ref = limit - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            newData[i] = data[i] || defaultValue;
          }
        }
        return newData;
      };

      Waveform.prototype.linearInterpolate = function(before, after, atPoint) {
        return before + (after - before) * atPoint;
      };

      Waveform.prototype.interpolateArray = function(data, fitCount) {
        var after, atPoint, before, i, newData, springFactor, tmp;
        newData = new Array();
        springFactor = new Number((data.length - 1) / (fitCount - 1));
        newData[0] = data[0];
        i = 1;
        while (i < fitCount - 1) {
          tmp = i * springFactor;
          before = new Number(Math.floor(tmp)).toFixed();
          after = new Number(Math.ceil(tmp)).toFixed();
          atPoint = tmp - before;
          newData[i] = this.linearInterpolate(data[before], data[after], atPoint);
          i++;
        }
        newData[fitCount - 1] = data[data.length - 1];
        return newData;
      };

      return Waveform;

    })();
    return Waveform;
  }
]);
; 
angular.module('mh').run(['$templateCache', function($templateCache) {
  'use strict';

  $templateCache.put('directives.background',
    "<div class=\"background\"></div>"
  );


  $templateCache.put('directives.bio',
    "<div class=\"bio\"><div ng-bind-html=\"safe()\" class=\"content\"></div></div>"
  );


  $templateCache.put('directives.discography',
    "<div class=\"discography\"><div class=\"controls\"><div ng-class=\"{actionable: active_index &gt; 0}\" class=\"left\"><button ng-click=\"nav(-1)\" class=\"ion icon left\"></button></div><div ng-class=\"{actionable: active_index &lt; playlists.length - 1}\" class=\"right\"><button ng-click=\"nav(1)\" class=\"ion icon right\"></button></div></div><div ng-repeat=\"playlist in playlists\" ng-class=\"{active: $index === active_index, prev: $index === active_index - 1, next: $index === (active_index + 1)}\" class=\"playlist-container\"><div mh-playlist=\"mh-playlist\" playlist=\"playlist\" index=\"$index\" colors=\"colors\" class=\"playlist\"></div></div></div>"
  );


  $templateCache.put('directives.footer',
    "<div class=\"footer\"><div class=\"inner\"><div class=\"social\"><a href=\"http://www.twitter.com/markhadleymusic\" class=\"icon twitter\"></a><a href=\"https://soundcloud.com/hadley-mark\" class=\"icon soundcloud\"></a><a href=\"http://www.youtube.com/user/MHQ89\" class=\"icon youtube\"></a><a href=\"mailto:mark@markhadleymusic.com\" class=\"icon ion email\"></a></div><div ng-attr-active=\"active\" class=\"links\"><a href=\"http://www.imdb.com/name/nm4837665/\" target=\"_blank\" class=\"normal\">imdb</a></div></div></div>"
  );


  $templateCache.put('directives.header',
    "<div class=\"header\"><div class=\"padding\"></div><div class=\"locker\"><div class=\"inner\"><div class=\"name-container\"><h1 ng-click=\"scroll()\" class=\"name normal\">Mark<em class=\"light\">Hadley</em></h1></div></div></div></div>"
  );


  $templateCache.put('directives.player',
    "<div class=\"player\"><div ng-if=\"track\" class=\"player-guts\"><div class=\"track-title\"><h2 class=\"title light\">{{track.title()}}</h2></div><div mh-waveform=\"track\" class=\"waveform\"></div><div class=\"player-controls\"><div class=\"actions\"><button ng-click=\"back()\" class=\"ion icon back\"></button><button ng-click=\"stop()\" ng-if=\"playing()\" class=\"ion icon stop\"></button><button ng-click=\"play()\" ng-if=\"!playing()\" class=\"ion icon play\"></button><button ng-click=\"close()\" class=\"ion icon close\"></button><button ng-click=\"next()\" class=\"ion icon next\"></button></div></div></div></div>"
  );


  $templateCache.put('directives.playlist',
    "<div class=\"playlist\"><div class=\"title-container\"><h1 class=\"light playlist-title\">{{playlist.title}}</h1></div><div class=\"player-container\"><div mh-player=\"mh-player\" track=\"active\" class=\"player\"></div></div><div class=\"playlist-guts\"></div></div>"
  );


  $templateCache.put('directives.waveform',
    "<div class=\"waveform\"></div>"
  );


  $templateCache.put('views.home',
    "<div class=\"home view\"><div class=\"container\"><div mh-discography=\"mh-discography\" playlists=\"playlists\" colors=\"colors\" class=\"discography\"></div><div mh-bio=\"mh-bio\" page=\"about_page\" class=\"bio\"></div></div></div>"
  );

}]);
