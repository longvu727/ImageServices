### There are two approach to execute and validate image services:
1.  Using http, apache2, perl, and perl-cgi to drive the server-client component
2.  Unit test in Services/Tests folder.  This is an easiest way to understand the Image Services.  See section 2 for the detail


### Using http, apache2, perl, and perl-cgi to drive the server-client component

##### Place the content of this folder to /var/www/perl
##### Images are stored in /var/www/images/
##### Add the following is the an addition to apache_conf for perl:
<code>
    
    `PerlSwitches -w
    PerlSwitches -T`

    Alias /perl /var/www/perl
    <Directory /var/www/perl>
        AddHandler perl-script .cgi .pl
        PerlResponseHandler ModPerl::PerlRun
        PerlOptions +ParseHeaders
        Options +ExecCGI
    </Directory>

    Alias /images /var/www/images
    <Directory /var/www/images>
            Options Indexes FollowSymLinks
            AllowOverride None
            Require all granted
    </Directory>

    <Location /perl-status>
        SetHandler perl-script
        PerlResponseHandler Apache2::Status
        Require ip 127.0.0.1 10.0.0.0/24
    </Location>
<code>

#### How to test:
##### images.cgi has many actions and display formats:

##### action=testupload -- a simple html form to browse and upload a file to server
http://127.0.0.1/perl/images.cgi?action=testupload

##### action=upload -- There are 2 ways to upload a file, 1. by link, 2. by http post; I chose http post;  Please test white testupload action
http://127.0.0.1/perl/images.cgi?action=upload&file=uploading_file_name

##### action=list -- list all image files in /var/www/images/
http://127.0.0.1/perl/images.cgi?action=list&format=web
http://127.0.0.1/perl/images.cgi?action=list&format=json

##### action=metadata -- obtain image file's properties and display the information
http://127.0.0.1/perl/images.cgi?action=metadata&file_name=images1.jpeg&format=web
http://127.0.0.1/perl/images.cgi?action=metadata&file_name=images1.jpeg&format=json

##### action=download -- download images in list service
http://127.0.0.1/perl/images.cgi?action=download&file_name=images1.jpeg&format=web
http://127.0.0.1/perl/images.cgi?action=download&file_name=images1.jpeg&format=json



### Unit test in Services/Tests folder
Services/Tests/ImageTest.pl has 1x1 pixel png image stored as binary data at the end of the file.  By using this data, an image can be uploaded, downloaded, listed, and extracted information( metadata ).

##### Sample Test
<code>
prove Services/Tests/ImageTest.pl 

Services/Tests/ImageTest.pl .. 1/4     # $list_result = [
    #                  'test.png',
    #                  'test.jpeg',
    #                  'images1.jpeg',
    #                  '1x1_pixel.png'
    #                ];
    # $metadata_result = {
    #                      'url' => '/var/www/images/1x1_pixel.png',
    #                      'ColorType' => 'Palette',
    #                      'FileAccessDate' => '2019:03:16 18:43:02-07:00',
    #                      'ImageWidth' => 1,
    #                      'ImageHeight' => 1,
    #                      'Directory' => '/var/www/images',
    #                      'Interlace' => 'Noninterlaced',
    #                      'FileSize' => '96 bytes',
    #                      'Filter' => 'Adaptive',
    #                      'FileInodeChangeDate' => '2019:03:16 18:43:02-07:00',
    #                      'Transparency' => '204',
    #                      'FileType' => 'PNG',
    #                      'FileName' => '1x1_pixel.png',
    #                      'ImageSize' => '1x1',
    #                      'Megapixels' => '0.000001',
    #                      'MIMEType' => 'image/png',
    #                      'FileModifyDate' => '2019:03:16 18:43:02-07:00',
    #                      'Compression' => 'Deflate/Inflate',
    #                      'BitDepth' => 1,
    #                      'FilePermissions' => 'rw-rw-r--',
    #                      'FileTypeExtension' => 'png',
    #                      'Warning' => '[minor] Trailer data after PNG IEND chunk',
    #                      'Palette' => '255 77 0',
    #                      'ExifToolVersion' => '11.30'

<code>
