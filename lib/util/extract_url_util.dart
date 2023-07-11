
class ExtractUrlUtil {

  static RegExp exp = new RegExp(r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");

  static String? getFirstUrl(String text) {
    Iterable<RegExpMatch> matches = exp.allMatches(text.toLowerCase());
    if(matches.length > 0) {
      return text.substring(matches.first.start, matches.first.end);
    }
    return null;
  }

  static String? getOriginUrl(String url) {
    url = url.replaceFirst("https://", "");
    url = url.replaceFirst("http://", "");
    int route = url.indexOf("/");
    if(route > 0) {
      url = url.substring(0, route);
    }
    return url;
  }

}