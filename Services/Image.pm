package Services::Image;

use warnings;
use strict;
use Data::Dumper;
use Image::ExifTool;

use Services::Response;
use Services::Conf;


sub new {
    my( $class, $args ) = @_;

    my $self = {
        image_path => $Services::Conf::IMAGE_PATH,
        host       => $args->{host} || $Services::Conf::DEFAULT_HOST
    };

    unless (-d $self->{image_path} ) {
        mkdir $self->{image_path};
    }

    bless $self, $class;
    return $self;
}

sub list {
    my( $self ) = @_;
    my $response = new Services::Response();

    opendir my $dh, $self->{image_path} || 
        return new Services::Response({ error => 'Cannot open dir' });

    my @files = grep{ $_ !~ /^(\.|\.\.)$/ } readdir $dh;

    return new Services::Response({ data => \@files });
}

sub download {
    my( $self, $file_name ) = @_;
    my $abs_filename = $self->{image_path} . $file_name;

    unless( -e $abs_filename ) {
        return new Services::Response({ error => 'File does not exist' });
    }

    open( IMG, $abs_filename ) ||
        return new Services::Response({ error => 'Unable to open file' });

    local $/;
    my $data = <IMG>;

    close(IMG);

    return new Services::Response({ data => $data });
}

sub upload {
    my( $self, $file_name, $file_data ) = @_;
    my $abs_filename = $self->{image_path} . $file_name;

    open (my $upload_fh, ">", $abs_filename) || 
        return new Services::Response({ error => 'Unable to upload file' });

    while (read ($file_data, my $buffer, 1024)) {
        print $upload_fh $buffer;
    }

    close $upload_fh;

    return new Services::Response({ data => 1 });
}

sub metadata {
    my( $self, $filename ) = @_;
    my $abs_filename = $self->{image_path} . $filename;

    unless( -e $abs_filename ) {
        return new Services::Response({ error => 'File does not exist' });
    }

    my $exif_tool = new Image::ExifTool;
    my $data = $exif_tool->ImageInfo($self->{image_path} . $filename);

    $data->{url} = $self->{host} . "/$filename";

    return new Services::Response({ data => $data });
}

1;
