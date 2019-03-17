#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use CGI;
use JSON::XS;

use lib '/var/www/perl/';
use Services::Image;


my $q = new CGI();
my $action = $q->param('action');
my $output_format = $q->param('format') || 'web';

my $image_service = new Services::Image({ host => $ENV{HTTP_HOST} });
my $response;

if( $action eq 'download' ) {
    my $file_name = $q->param('file_name');

    $response = $image_service->download( $file_name );
    my $output = {
        data => $response->data(),
        file_name => $file_name,
    };
    
    if( !$response->error() ) {
        if( $output_format eq 'web' ) {
            output( $q, $output, 'download' );
        }
        else {
            output( $q, $output, $output_format );
        }
    }
}
elsif( $action eq 'upload' ) {
    my $file_name = $q->param('file');
    my $file_data = $q->upload("file"); 

    $response = $image_service->upload( $file_name, $file_data );
    
    output( $q, $response->data(), $output_format ) if( !$response->error() );
}
elsif( $action eq 'metadata' ) {
    my $filename = $q->param('file_name');
    $response = $image_service->metadata( $filename );
    
    output( $q, $response->data(), $output_format ) if( !$response->error() );
}
elsif( $action eq 'testupload' ) {
    my $html = qq~
        <form enctype="multipart/form-data" method=post>
            <input type="hidden" name="action" value="upload">
            <input type="file" name="file">
            <input type=submit value=Upload>
        </form>
    ~;

    output( $q, $html, 'html' );
}
else {
    #list
    $response = $image_service->list();

    output( $q, $response->data(), $output_format ) if( !$response->error() );
}

sub output_to_download {
    my( $q, $data ) = @_;

    print $q->header(
        -type => "application/x-download",
        -attachment => "$data->{file_name}" 
    );

    print $data->{data};
}

sub output {
    my( $q, $data, $type ) = @_;
    my $body;

    if( $type eq 'download' ) {
        output_to_download( $q, $data );
    }
    elsif( $type eq 'json' ) {
        $body = JSON::XS->new->pretty(1)->encode( $data );
        print "Content-type: text\n\n $body";
    }
    elsif( $type eq 'html' ) {
        print "Content-type: text/html\n\n $data";
    }
    else {
        $body = Data::Dumper->Dump( [$data], [qw(result)] );
        print "Content-type: text\n\n $body";
    }

}

1;


