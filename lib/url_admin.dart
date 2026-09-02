String myWebHost = 'https://workwithshubh.online/';
String myDir = 'music_apis/';
String baseUrl = "$myWebHost$myDir";

String adminLoginUrl = "${baseUrl}admin_login.php";
String adminLogoutUrl = "${baseUrl}admin_logout.php";
String adminAddSongsUrl = "${baseUrl}admin_add_songs.php";
String adminGetAllSongsUrl = "${baseUrl}get_all_songs.php";
String adminUpdateSongUrl = "${baseUrl}admin_update_song.php";
String adminDeleteSongUrl = "${baseUrl}admin_delete_song.php";
String addToQuickPicksUrl = "${baseUrl}add_to_quick_picks.php";
String getQuickPicksUrl = "${baseUrl}get_quick_picks.php";
String removeFromQuickPicksUrl = "${baseUrl}remove_from_quick_picks.php";

/// Install and active-user counts for the home page's Listeners card.
/// Admin-only — it goes out through [authDio], not a bare Dio.
String getAppStatsUrl = "${baseUrl}get_app_stats.php";

String getAllArtistsUrl = "${baseUrl}get_all_artists.php";
String getArtistDetailsUrl = "${baseUrl}get_artist_details.php";
String createArtistUrl = "${baseUrl}create_artist.php";
String updateArtistUrl = "${baseUrl}update_artist.php";
String deleteArtistUrl = "${baseUrl}delete_artist.php";
String addSongToArtistUrl = "${baseUrl}add_song_to_artist.php";
