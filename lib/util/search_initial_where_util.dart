class SearchInitialUtil {

  static const int HANGUL_BEGIN_UNICODE = 44032; // 가
  static const int HANGUL_LAST_UNICODE = 55203; // 힣
  static const int HANGUL_BASE_UNIT = 588; //각 자음 마다 가지는 글자수

  static const List<String> INITIAL_SOUND = [ 'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ',
    'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ' ];


  /** * 해당 문자가 INITIAL_SOUND인지 검사. * @param searchar * @return */
  static bool isInitialSound(String searchar){
    for(int i = 0; i < INITIAL_SOUND.length; i++) {
      if(INITIAL_SOUND[i] == searchar[0]) {
        return true;
      }
    }
    return false;
  }

  /** * 해당 문자의 자음을 얻는다. * * @param c 검사할 문자 * @return */
  static String getInitialSound(String c) {
    int hanBegin = (c.codeUnitAt(0) - HANGUL_BEGIN_UNICODE);
    int index = hanBegin ~/ HANGUL_BASE_UNIT;
    return INITIAL_SOUND[index];
  }
  /** * 해당 문자가 한글인지 검사 * @param c 문자 하나 * @return */
  static bool isHangul(String c) {
    return HANGUL_BEGIN_UNICODE <= c.codeUnitAt(0) && c.codeUnitAt(0) <= HANGUL_LAST_UNICODE;
  }

  /** * 검색을 한다. 초성 검색 완벽 지원함. * @param value : 검색 대상 ex> 초성검색합니다 * @param search : 검색어 ex> ㅅ검ㅅ합ㄴ * @return 매칭 되는거 찾으면 true 못찾으면 false. */
  static bool matchString(String value, String search){
    int t = 0;
    int seof = value.length - search.length;
    int slen = search.length;

    if(seof < 0)
      return false; //검색어가 더 길면 false를 리턴한다.

    for(int i = 0;i <= seof;i++){
      t = 0;

      while(t < slen) {
        if(isInitialSound(search[t])==true && isHangul(value[i+t])){ //만약 현재 char이 초성이고 value가 한글이면
           if(getInitialSound(value[i+t])==search[t]) //각각의 초성끼리 같은지 비교한다
             t++;
           else
             break;
        } else { //char이 초성이 아니라면
          if(value[i+t] == search[t]) //그냥 같은지 비교한다.
            t++;
          else
            break;
        }
      }

      if(t == slen)
        return true; //모두 일치한 결과를 찾으면 true를 리턴한다.
    }
    return false; //일치하는 것을 찾지 못했으면 false를 리턴한다.
  }
}