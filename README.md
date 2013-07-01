HTML-Repetitive-Detection
=========================

lib 디렉토리 안에 내아이디.pm 파일을 만들고,

    #!/usr/bin/env perl
    
    sub detect{
      my $str = shift;
      my @chunks;
      
      ....
      
      return @chunks;
    }
    
    1;
    
와 같이 작성하시면 되구요.

    perl test.pl lib/내아이디.pm 

하시면 하나만 테스트하고

    perl test.pl 

하시면 모두 테스트 합니다.
