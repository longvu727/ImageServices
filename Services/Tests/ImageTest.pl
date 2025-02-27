use Cwd qw(abs_path);
use File::Basename;
use lib dirname dirname dirname abs_path __FILE__;
use Services::Image;
use Test::More tests => 4;

my $pixel_file_name = '1x1_pixel.png';

subtest 'Test Services::Image->upload' => sub {

    my $images_services  = new Services::Image();
    my $response = $images_services->upload( $pixel_file_name, \*DATA );

    is( $response->data(), 1, "Image uploaded" );
};

subtest 'Test Services::Image->List' => sub {
    my $images_services  = new Services::Image();
    my $response = $images_services->list();

    my( $pixel_image ) = grep{ $_ eq $pixel_file_name } @{ $response->data() };

    diag( Data::Dumper->Dump([$response->data()], ['list_result']) );
    ok( $pixel_image, "List -- found $pixel_image" );
};

subtest 'Test Services::Image->download' => sub {
    my $images_services  = new Services::Image();
    my $response = $images_services->download( $pixel_file_name );
    
    ok( length $response->data(), "$pixel_file_name downloaded" );
};

subtest 'Test Services::Image->metadata' => sub {
    my $images_services  = new Services::Image();
    my $response = $images_services->metadata( $pixel_file_name );

    diag( Data::Dumper->Dump([$response->data()], ['metadata_result']) );
    ok( $response->data(), "$pixel_file_name metadata shown" )
};


__DATA__
�PNG

   IHDR         %�V�   PLTE�M \58   tRNS��4V�   
IDATx�cb    67|�    IEND�B`�
