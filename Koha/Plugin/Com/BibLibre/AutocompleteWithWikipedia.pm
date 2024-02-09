package Koha::Plugin::Com::BibLibre::AutocompleteWithWikipedia;

use Modern::Perl;

use base qw(Koha::Plugins::Base);

use C4::Context;

our $VERSION = '0.2';

our $metadata = {
    name   => 'AutocompleteWithWikipedia',
    author => 'BibLibre',
    description => 'Autocomplete search terms with Wikipedia datas via its API',
    date_authored   => '2024-02-09',
    date_updated    => '2024-02-09',
    minimum_version => '18.11',
    maximum_version => undef,
    version         => $VERSION,
};

sub new {
    my ( $class, $args ) = @_;

    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    my $self = $class->SUPER::new($args);

    return $self;
}

# Mandatory even if does nothing
sub install {
    my ( $self, $args ) = @_;

    return 1;
}

# Mandatory even if does nothing
sub upgrade {
    my ( $self, $args ) = @_;

    return 1;
}

# Mandatory even if does nothing
sub uninstall {
    my ( $self, $args ) = @_;

    return 1;
}

sub opac_head {

    return q%
<link href="/intranet-tmpl/lib/jquery/jquery-ui-1.13.1.min.css" rel="stylesheet" type="text/css">
%;
}

sub opac_js {
    my ( $self ) = @_;

    # Needs Jquery UI autocomplete lib from staff interface
    return q%
<script src="/intranet-tmpl/lib/jquery/jquery-ui-1.13.1.min.js"></script>
<script>

// Get API URL with current lang
var currlang = ($("html").attr("lang") || "en").split("-")[0];
var apiurl = "https://" + currlang + ".wikipedia.org/w/api.php";

$("#searchform input[name='q']").autocomplete({
  source: function(request, response) {
    $.ajax({
      url: apiurl,
      dataType: "json",
      data: {
        "action": "opensearch",
        "limit" : 16,
        "format": "json",
        "origin": "*",
        "search": request.term
      },
      success: function(data) {
        var pages = data[1].map(function(page) {
            // remove context text, will generate duplicates
            return page.replace(/\(.*\)/g,"").trim();
        });
        // return only first 8 results
        response(removeDuplicates(pages,8));
      }
    });
  },
  minLength: 3,
  open: function() {
    // nothing for now
  }
});

// Remove duplicates in Array and truncate size to a limit
function removeDuplicates(arr,limit) {
    var unique = [];
    for (i = 0; i < arr.length && unique.length < limit; i++) {
        if (unique.indexOf(arr[i]) === -1) {
            unique.push(arr[i]);
        }
    }
    return unique;
}

</script>
%;
}

1;
