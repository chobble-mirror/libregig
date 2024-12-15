{
  actioncable = {
    dependencies = ["actionpack" "activesupport" "nio4r" "websocket-driver" "zeitwerk"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03dai8z2dxb2cf29hp6md7bhysyipxvw2qnm2bj98yyrnaskfikn";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  actionmailbox = {
    dependencies = ["actionpack" "activejob" "activerecord" "activestorage" "activesupport" "mail" "net-imap" "net-pop" "net-smtp"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02inlpsmjz8rz159ljhzac1dvzq5k1pnmmx2pf4gmrj3zs4hbhn3";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  actionmailer = {
    dependencies = ["actionpack" "actionview" "activejob" "activesupport" "mail" "net-imap" "net-pop" "net-smtp" "rails-dom-testing"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ncplhcrxldj6jvbaw9g8ik4cznjlf3lyfzgrwy0jfxjh3cdc4xj";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  actionpack = {
    dependencies = ["actionview" "activesupport" "nokogiri" "racc" "rack" "rack-session" "rack-test" "rails-dom-testing" "rails-html-sanitizer"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "066p70mngqk8m7qp3wq2frbl1w8imdcrdxb06cxwq5izykcn7hib";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  actiontext = {
    dependencies = ["actionpack" "activerecord" "activestorage" "activesupport" "globalid" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1v7psa946frm79x04vywnd0h069jgxy5xghm7y5sgijvmp7n3qmq";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  actionview = {
    dependencies = ["activesupport" "builder" "erubi" "rails-dom-testing" "rails-html-sanitizer"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1apnqjfwbvyhf7svlamal1pvy2x78fk42lqbnllqwy816lhrlmcc";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  activejob = {
    dependencies = ["activesupport" "globalid"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rspwfvhxs5by6im90rrjp2sy1wzdpcgb9xm0qfljk3zhmn3fcvn";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  activemodel = {
    dependencies = ["activesupport"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wci45aas8g909zby9j91m87ff5j28qwl0i7izzbszsahmk78wkl";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  activerecord = {
    dependencies = ["activemodel" "activesupport" "timeout"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qzij5xmsqqxsc9v9kil68aif5bvly06vqf4pnjrnfzkkdhd22pl";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  activestorage = {
    dependencies = ["actionpack" "activejob" "activerecord" "activesupport" "marcel"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qzz8dxwj70zys1lmqk1x0sl4rb7ddw6v2bgmpm6dijqd03qnsxf";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  activesupport = {
    dependencies = ["base64" "benchmark" "bigdecimal" "concurrent-ruby" "connection_pool" "drb" "i18n" "logger" "minitest" "mutex_m" "securerandom" "tzinfo"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1f6gqyl49hdabid5jkrfq0127gd396srsgpy7p5ni61v8wp4h34z";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cl2qpvwiffym62z991ynks7imsm87qmgxf0yfsmlwzkgi9qcaa6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.8.7";
  };
  ast = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04nc8x27hlzlrr5c2gn7mar4vdr0apw5xg22wp6m8dx3wqr04a0y";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.4.2";
  };
  base64 = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01qml0yilb9basf7is2614skjp8384h2pycfx86cr8023arfj98g";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.2.0";
  };
  bcrypt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16a0g2q40biv93i1hch3gw8rbmhp77qnnifj1k0a6m7dng3zh444";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.20";
  };
  benchmark = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jl71qcgamm96dzyqk695j24qszhcc7liw74qc83fpjljp2gh4hg";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.4.0";
  };
  better_html = {
    dependencies = ["actionview" "activesupport" "ast" "erubi" "parser" "smart_properties"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mdgwlc02f43svy92p0k5v1hipibpzxcdjm774lkz2j8s58kav04";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.1.1";
  };
  bigdecimal = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gi7zqgmqwi5lizggs1jhc3zlwaqayy9rx2ah80sxy24bbnng558";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.8";
  };
  bindex = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zmirr3m02p52bzq4xgksq4pn8j641rx5d4czk68pv9rqnfwq7kv";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.8.1";
  };
  bootsnap = {
    dependencies = ["msgpack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mdgj9yw1hmx3xh2qxyjc31y8igmxzd9h0c245ay2zkz76pl4k5c";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.18.4";
  };
  builder = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pw3r2lyagsxkm71bf44v5b74f7l9r7di22brbyji9fwz791hya9";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.3.0";
  };
  capybara = {
    dependencies = ["addressable" "matrix" "mini_mime" "nokogiri" "rack" "rack-test" "regexp_parser" "xpath"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vxfah83j6zpw3v5hic0j70h519nvmix2hbszmjwm8cfawhagns2";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.40.0";
  };
  childprocess = {
    dependencies = ["logger"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1v5nalaarxnfdm6rxb7q6fmc6nx097jd630ax6h9ch7xw95li3cs";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.1.0";
  };
  concurrent-ruby = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0chwfdq2a6kbj6xz9l6zrdfnyghnh32si82la1dnpa5h75ir5anl";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.3.4";
  };
  connection_pool = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x32mcpm2cl5492kd6lbjbaf17qsssmpx9kdyr7z1wcif2cwyh0g";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.4.1";
  };
  crass = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pfl5c0pyqaparxaqxi6s4gfl21bdldwiawrc0aknyvflli60lfw";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.0.6";
  };
  date = {
    groups = ["default" "development" "test"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "mingw";
    } {
      engine = "mswin";
    } {
      engine = "mswin64";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kz6mc4b9m49iaans6cbx031j9y7ldghpi5fzsdh0n3ixwa8w9mz";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.4.1";
  };
  debug = {
    dependencies = ["irb" "reline"];
    groups = ["development" "test"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "mingw";
    } {
      engine = "mswin";
    } {
      engine = "mswin64";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1z77qyzcmvz3ciny6cb24s79a243jqkybqk30b310yichp02dq28";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.9.2";
  };
  docile = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07pj4z3h8wk4fgdn6s62vw1lwvhj0ac0x10vfbdkr9xzk7krn5cn";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.4.1";
  };
  dotenv = {
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1hffaq70wkcqkwpd1j70ykikn541lcx78m2dhl4y7x9cim02v6vx";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.6";
  };
  drb = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h5kbj9hvg5hb3c7l425zpds0vb42phvln2knab8nmazg2zp5m79";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.2.1";
  };
  erb_lint = {
    dependencies = ["activesupport" "better_html" "parser" "rainbow" "rubocop" "smart_properties"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vn2ssgid25fknmcla3k3gxym4l5ymn7hvggs33q11frc9zp53ki";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.7.0";
  };
  erubi = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qnd6ff4az22ysnmni3730c41b979xinilahzg86bn7gv93ip9pw";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.13.0";
  };
  factory_bot = {
    dependencies = ["activesupport"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0q927lvgjqj0xaplxhicj5xv8xadx3957mank3p7g01vb6iv6x33";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.5.0";
  };
  factory_bot_rails = {
    dependencies = ["factory_bot" "railties"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "122wkrc3d2q1dlca27794hh3arw0kvrf3rgmvn7hj3y5lb51g7hk";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.4.4";
  };
  fast_ignore = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kp19p3b4l3h03yrpzcd70l6vycv8kgpbaqx4j0rycf1rw5f78jk";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.17.4";
  };
  ffi = {
    groups = ["default"];
    platforms = [];
    source = null;
    targets = [{
      remotes = ["https://rubygems.org"];
      sha256 = "1621lgx1isrwjj4j27lvlxjfd6v3pnq2ahvhn2y6pp8rb6fya58h";
      target = "x86_64-linux-gnu";
      targetCPU = "x86_64";
      targetOS = "linux";
      type = "gem";
    }];
    version = "1.17.0";
  };
  globalid = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sbw6b66r7cwdx3jhs46s4lr991969hvigkjpbdl7y3i31qpdgvh";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.1";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0k31wcgnvcvd14snz0pfqj976zv6drfsnq6x8acz10fiyms9l8nw";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.14.6";
  };
  io-console = {
    groups = ["default" "development" "test"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "mingw";
    } {
      engine = "mswin";
    } {
      engine = "mswin64";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18pgvl7lfjpichdfh1g50rpz0zpaqrpr52ybn9liv1v9pjn9ysnd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.8.0";
  };
  irb = {
    dependencies = ["rdoc" "reline"];
    groups = ["default" "development" "test"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "mingw";
    } {
      engine = "mswin";
    } {
      engine = "mswin64";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ii34xa9m9n2vrrmhb3rq01xn7c684pad02382rbw5ci87v40c14";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.14.2";
  };
  jbuilder = {
    dependencies = ["actionview" "activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mi7s8kida8rg754bzgiik2mpdwx55x7wxd9ny0sm0803j5a603j";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.13.0";
  };
  json = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kvbzh8530pp3qf63zvx9hnb708x7plv9wfn5ibns3h3knnvs3kw";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.9.0";
  };
  language_server-protocol = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gvb1j8xsqxms9mww01rmdl78zkd72zgxaap56bhv8j45z05hp1x";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.17.0.3";
  };
  launchy = {
    dependencies = ["addressable" "childprocess"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0b3zi9ydbibyyrrkr6l8mcs6l7yam18a4wg22ivgaz0rl2yn1ymp";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.0.1";
  };
  leftovers = {
    dependencies = ["fast_ignore" "parallel" "parser"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14grlmrwmy9r8r40lmfa9ys92wq2jvm1w7an5afjvbc9apxaf9l8";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.12.2";
  };
  letter_opener = {
    dependencies = ["launchy"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cnv3ggnzyagl50vzs1693aacv08bhwlprcvjp8jcg2w7cp3zwrg";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.10.0";
  };
  lint_roller = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11yc0d84hsnlvx8cpk4cbj6a4dz9pk0r1k29p0n1fz9acddq831c";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.1.0";
  };
  logger = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1574gi74z5pww36rv0jvqlv9ybm87h7c37fb5r2axn3mbh0wwcs5";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.6.3";
  };
  loofah = {
    dependencies = ["crass" "nokogiri"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ppp2cgli5avzk0z3dwnah6y65ymyr793yja28p2fs9vrci7986h";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.23.1";
  };
  mail = {
    dependencies = ["mini_mime" "net-imap" "net-pop" "net-smtp"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bf9pysw1jfgynv692hhaycfxa8ckay1gjw5hz3madrbrynryfzc";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.8.1";
  };
  marcel = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "190n2mk8m1l708kr88fh6mip9sdsh339d2s6sgrik3sbnvz4jmhd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.0.4";
  };
  matrix = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1h2cgkpzkh3dd0flnnwfq6f3nl2b1zff9lvqz8xs853ssv5kq23i";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.4.2";
  };
  mini_mime = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vycif7pjzkr29mfk4dlqv3disc5dn0va04lkwajlpr1wkibg0c6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.1.5";
  };
  minitest = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0izrg03wn2yj3gd76ck7ifbm9h2kgy8kpg4fk06ckpy4bbicmwlw";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.25.4";
  };
  mocha = {
    dependencies = ["ruby2_keywords"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lgqyxxdxgfik77a7lk2hjkr6flimgxr4gcbg3y7bg1ybn6m6zcg";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.7.1";
  };
  msgpack = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a5fsgchkpcca4wf3pipbb2jbj523l7fbaq37j10cr0yymwlkc7z";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.7.5";
  };
  mutex_m = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0l875dw0lk7b2ywa54l0wjcggs94vb7gs8khfw9li75n2sn09jyg";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.3.0";
  };
  net-imap = {
    dependencies = ["date" "net-protocol"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mrqr1xknw4z1nzjvdaff1gd504fkwaqdb6ibqfhixsrhifvikn0";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.5.1";
  };
  net-pop = {
    dependencies = ["net-protocol"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wyz41jd4zpjn0v1xsf9j778qx1vfrl24yc20cpmph8k42c4x2w4";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.2";
  };
  net-protocol = {
    dependencies = ["timeout"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a32l4x73hz200cm587bc29q8q9az278syw3x6fkc9d1lv5y0wxa";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.2.2";
  };
  net-smtp = {
    dependencies = ["net-protocol"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0amlhz8fhnjfmsiqcjajip57ici2xhw089x7zqyhpk51drg43h2z";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.5.0";
  };
  nio4r = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a9www524fl1ykspznz54i0phfqya4x45hqaz67in9dvw1lfwpfr";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.7.4";
  };
  nokogiri = {
    dependencies = ["racc"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = null;
    targets = [{
      remotes = ["https://rubygems.org"];
      sha256 = "02xyf1nlyj31wl4ik83az9y5vq3sbqvi9a2wagdrmgbnszl4lqg8";
      target = "x86_64-linux";
      targetCPU = "x86_64";
      targetOS = "linux";
      type = "gem";
    }];
    version = "1.17.2";
  };
  parallel = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vy7sjs2pgz4i96v5yk9b7aafbffnvq7nn419fgvw55qlavsnsyq";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.26.3";
  };
  parallel_tests = {
    dependencies = ["parallel"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04i61bkra454var9dc79ak3yffl13mbqx8xv2rvidx9n7ins9cyn";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.7.2";
  };
  parser = {
    dependencies = ["ast" "racc"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fxw738al3qxa4s4ghqkxb908sav03i3h7xflawwmxzhqiyfdm15";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.3.6.0";
  };
  prosopite = {
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yby2z4xh5ah3x2wvsjm6n1v7b8lzr935v8d2chcxwyvv7i25r5j";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.4.2";
  };
  psych = {
    dependencies = ["date" "stringio"];
    groups = ["default" "development" "test"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "mingw";
    } {
      engine = "mswin";
    } {
      engine = "mswin64";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rmbdvxqashvivk95778s6c7qba7xa0ayvjqj2bkzpz944fl9j7n";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.2.1";
  };
  public_suffix = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vqcw3iwby3yc6avs1vb3gfd0vcp2v7q310665dvxfswmcf4xm31";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.0.1";
  };
  puma = {
    dependencies = ["nio4r"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wl9q4fl8gvhwdpfxghx6jdqi4508287pcgiwi96sdbzmdfbglcl";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.5.0";
  };
  racc = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0byn0c9nkahsl93y9ln5bysq4j31q8xkf2ws42swighxd4lnjzsa";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.8.1";
  };
  rack = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cd13019gnnh2c0a3kj27ij5ibk72v0bmpypqv4l6ayw8g5cpyyk";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.8";
  };
  rack-session = {
    dependencies = ["rack"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10afdpmy9kh0qva96slcyc59j4gkk9av8ilh58cnj0qq7q3b416v";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.0.0";
  };
  rack-test = {
    dependencies = ["rack"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ysx29gk9k14a14zsp5a8czys140wacvp91fja8xcja0j1hzqq8c";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.1.0";
  };
  rackup = {
    dependencies = ["rack"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13brkq5xkj6lcdxj3f0k7v28hgrqhqxjlhd4y2vlicy5slgijdzp";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.2.1";
  };
  rails = {
    dependencies = ["actioncable" "actionmailbox" "actionmailer" "actionpack" "actiontext" "actionview" "activejob" "activemodel" "activerecord" "activestorage" "activesupport" "railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0148c00v3hks98rymdiilhjm0i8qw5fla4gww0fb94k3ggns5bh5";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  rails-controller-testing = {
    dependencies = ["actionpack" "actionview" "activesupport"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "151f303jcvs8s149mhx2g5mn67487x0blrf9dzl76q1nb7dlh53l";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.0.5";
  };
  rails-dom-testing = {
    dependencies = ["activesupport" "minitest" "nokogiri"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fx9dx1ag0s1lr6lfr34lbx5i1bvn3bhyf3w3mx6h7yz90p725g5";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.2.0";
  };
  rails-html-sanitizer = {
    dependencies = ["loofah" "nokogiri"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0q55i6mpad20m2x1lg5pkqfpbmmapk0sjsrvr1sqgnj2hb5f5z1m";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.6.2";
  };
  railties = {
    dependencies = ["actionpack" "activesupport" "irb" "rackup" "rake" "thor" "zeitwerk"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yz28fq55drl4c2dwgap96xcjf6qns2ghc3c3gffzm6yw9i5bq8b";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.5.1";
  };
  rainbow = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.1";
  };
  rake = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17850wcwkgi30p7yqh60960ypn7yibacjjha0av78zaxwvd3ijs6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "13.2.1";
  };
  rdoc = {
    dependencies = ["psych"];
    groups = ["default" "development" "test"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "mingw";
    } {
      engine = "mswin";
    } {
      engine = "mswin64";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02djakm481k2lbvgkjcn5bfy62nymy7b7s7lqzcc58v6mh9x5aci";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.9.0";
  };
  regexp_parser = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yb3iycaj3krvlnicijm99qxvfbrbi0pd81i2cpdhjc3xmbhcqjb";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.9.3";
  };
  reline = {
    dependencies = ["io-console"];
    groups = ["default" "development" "test"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "mingw";
    } {
      engine = "mswin";
    } {
      engine = "mswin64";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18jml0hcrk4g70j0wdi90l9m2psqp69jmf7qk6g1daiazp9kdas1";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.5.12";
  };
  rexml = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ch4k2y80r4glr579kxliqnxld2qa91ydq8fiqam38bzpbps3gpg";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.4.0";
  };
  rubocop = {
    dependencies = ["json" "language_server-protocol" "parallel" "parser" "rainbow" "regexp_parser" "rubocop-ast" "ruby-progressbar" "unicode-display_width"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1f2bj93f60757xyk7h3v0s7xz8d22lc9zlw88l2zd6rp1brv0bvn";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.69.2";
  };
  rubocop-ast = {
    dependencies = ["parser"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10604xc4bcji3ca43anlc89xwxb4wkzk69cia95x04zima4aq4wm";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.37.0";
  };
  rubocop-performance = {
    dependencies = ["rubocop" "rubocop-ast"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wcilipyh890k0vwx8mgkj5qpjy2xvvgk89l9ars1wf53g5pibil";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.23.0";
  };
  rubocop-rails = {
    dependencies = ["activesupport" "rack" "rubocop" "rubocop-ast"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bc4xpyx0gldjdmbl9aaqav5bjiqfc2zdw7k2r1zblmgsq4ilmpm";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.26.2";
  };
  ruby-progressbar = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.13.0";
  };
  ruby2_keywords = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vz322p8n39hz3b4a9gkmz9y7a5jaz41zrm2ywf31dvkqm03glgz";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.0.5";
  };
  rubyzip = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0grps9197qyxakbpw02pda59v45lfgbgiyw48i0mq9f2bn9y6mrz";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.3.2";
  };
  sassc = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gpqv48xhl8mb8qqhcifcp0pixn206a7imc07g48armklfqa4q2c";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.4.0";
  };
  sassc-rails = {
    dependencies = ["railties" "sassc" "sprockets" "sprockets-rails" "tilt"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1d9djmwn36a5m8a83bpycs48g8kh1n2xkyvghn7dr6zwh4wdyksz";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.1.2";
  };
  securerandom = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a2k1bd7s2192sxa2m7frhvcck8xaf8mzhsvgkjcinp49ym49a1p";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.4.0";
  };
  selenium-webdriver = {
    dependencies = ["base64" "logger" "rexml" "rubyzip" "websocket"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1q5nbszbxz566yzyiv0a4lvfk56q89k0lk4mqp6wyddrc2nz88c8";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.27.0";
  };
  shoulda-context = {
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0d1clcp92jv8756h09kbc55qiqncn666alx0s83za06q5hs4bpvs";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.0.0";
  };
  shoulda-matchers = {
    dependencies = ["activesupport"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1c082vpfdf3865xq6xayxw2hwqswhnc9g030p1gi4hmk9dzvnmch";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.4.0";
  };
  simplecov = {
    dependencies = ["docile" "simplecov-html" "simplecov_json_formatter"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "198kcbrjxhhzca19yrdcd6jjj9sb51aaic3b0sc3pwjghg3j49py";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.22.0";
  };
  simplecov-html = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02zi3rwihp7rlnp9x18c9idnkx7x68w6jmxdhyc0xrhjwrz0pasx";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.13.1";
  };
  simplecov-json = {
    dependencies = ["json" "simplecov"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1xw1w8wfggwc6rcz5640ssynd888bxv52hmr9kzqap69vysj6f66";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.2.3";
  };
  simplecov_json_formatter = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0a5l0733hj7sk51j81ykfmlk2vd5vaijlq9d5fn165yyx3xii52j";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.4";
  };
  smart_properties = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jrqssk9qhwrpq41arm712226vpcr458xv6xaqbk8cp94a0kycpr";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.17.0";
  };
  sprockets = {
    dependencies = ["concurrent-ruby" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15rzfzd9dca4v0mr0bbhsbwhygl0k9l24iqqlx0fijig5zfi66wm";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.2.1";
  };
  sprockets-rails = {
    dependencies = ["actionpack" "activesupport" "sprockets"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17hiqkdpcjyyhlm997mgdcr45v35j5802m5a979i5jgqx5n8xs59";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.5.2";
  };
  sqlite3 = {
    groups = ["default"];
    platforms = [];
    source = null;
    targets = [{
      remotes = ["https://rubygems.org"];
      sha256 = "0wzflcbl468linz00286g46xnwz8h1wwk02q8r9q5v0dcs2k4ajj";
      target = "x86_64-linux";
      targetCPU = "x86_64";
      targetOS = "linux";
      type = "gem";
    }];
    version = "1.7.3";
  };
  standard = {
    dependencies = ["language_server-protocol" "lint_roller" "rubocop" "standard-custom" "standard-performance"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15qwp65cd2kddnryppxmyb8srr8dwi4w62w5mri82fiq0svqmnmj";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.43.0";
  };
  standard-custom = {
    dependencies = ["lint_roller" "rubocop"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0av55ai0nv23z5mhrwj1clmxpgyngk7vk6rh58d4y1ws2y2dqjj2";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.0.2";
  };
  standard-performance = {
    dependencies = ["lint_roller" "rubocop-performance"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x298w3wmq8cavbsg903wc3arxp3xh2x8263brvy128436m732rd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.6.0";
  };
  standard-rails = {
    dependencies = ["lint_roller" "rubocop-rails"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1w7m3yfhvplp4qzv2ygk95ys2g8dcyl5jwq4gllxinl0fdpvxmg8";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.0";
  };
  stringio = {
    groups = ["default" "development" "test"];
    platforms = [{
      engine = "maglev";
    } {
      engine = "mingw";
    } {
      engine = "mswin";
    } {
      engine = "mswin64";
    } {
      engine = "ruby";
    }];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cd1kdrf62p2ya3ia4rz49d5012bqinvqjmcgkakknswz0l1hkr0";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.2";
  };
  thor = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nmymd86a0vb39pzj2cwv57avdrl6pl3lf5bsz58q594kqxjkw7f";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.3.2";
  };
  tilt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kds7wkxmb038cwp6ravnwn8k65ixc68wpm8j5jx5bhx8ndg4x6z";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.4.0";
  };
  timeout = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06fcniirx82hrljzfn5wb3634n8648v8qgy006jzgclfz5gjvjla";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.4.2";
  };
  tzinfo = {
    dependencies = ["concurrent-ruby"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16w2g84dzaf3z13gxyzlzbf748kylk5bdgg3n1ipvkvvqy685bwd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.0.6";
  };
  unicode-display_width = {
    dependencies = ["unicode-emoji"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lcmyip9rw4azsia1hb5srj2mgbdhrinc4113cs1w84qz1ndpm7x";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.2";
  };
  unicode-emoji = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ajk6rngypm3chvl6r0vwv36q1931fjqaqhjjya81rakygvlwb1c";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.0.4";
  };
  web-console = {
    dependencies = ["actionview" "activemodel" "bindex" "railties"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "087y4byl2s3fg0nfhix4s0r25cv1wk7d2j8n5324waza21xg7g77";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.2.1";
  };
  websocket = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0dr78vh3ag0d1q5gfd8960g1ca9g6arjd2w54mffid8h4i7agrxp";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.11";
  };
  websocket-driver = {
    dependencies = ["websocket-extensions"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nyh873w4lvahcl8kzbjfca26656d5c6z3md4sbqg5y1gfz0157n";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.7.6";
  };
  websocket-extensions = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hc2g9qps8lmhibl5baa91b4qx8wqw872rgwagml78ydj8qacsqw";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.5";
  };
  xpath = {
    dependencies = ["nokogiri"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bh8lk9hvlpn7vmi6h4hkcwjzvs2y0cmkk3yjjdr8fxvj6fsgzbd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.2.0";
  };
  zeitwerk = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mi7b90hvc6nqv37q27df4i2m27yy56yfy2ki5073474a1h9hi89";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.7.1";
  };
}