package Koha::Plugin::Com::BibLibre::AutocompleteWithWikipedia;

use Modern::Perl;

use base qw(Koha::Plugins::Base);

use C4::Context;

our $VERSION = '0.1';

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

sub opac_js {
    my ( $self ) = @_;

    return q%
<script>
$("#searchform input[name='q']").autocomplete({
  source: function(request, response) {
    $.ajax({
      url: "https://fr.wikipedia.org/w/api.php",
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
