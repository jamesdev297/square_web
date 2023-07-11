
class SearchInitialQueryUtil {
  static const int EVENT_CODE_LENGTH = 6;

  static const int DIGIT_BEGIN_UNICODE = 0x30; //0
  static const int DIGIT_END_UNICODE = 0x3A; //9

  static const int QUERY_DELIM = 39;//'
  static const int LARGE_ALPHA_BEGIN_UNICODE = 0;

  static const int HANGUL_BEGIN_UNICODE = 0xAC00; // 가
  static const int HANGUL_END_UNICODE = 0xD7A3; // ?
  static const int HANGUL_CHO_UNIT = 588; //한글 초성글자간 간격
  static const int HANGUL_JUNG_UNIT = 28; //한글 중성글자간 간격

  static const List<String> INITIAL_SOUND_LIST = [ 'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ',
  'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ' ];

  static const List<bool> INITIAL_SOUND_SEARCH_LIST = [ true, false, true, true, false, true,
  true, true, false, true, false, true, true, false, true, true, true, true, true];

  /*
   * 문자를 유니코드(10진수)로 변환 후 반환한다.
   * @param ch 문자
   * @return 10진수 유니코드
   */
  static int convertCharToUnicode(String ch) {
    return ch.codeUnitAt(0).toInt();
  }

  /*
   * 유니코드(10진수)를 문자로 변환 후 반환한다.
   * @param unicode
   * @return 문자값
   */
  static String convertUnicodeToChar(int unicode) {
    return String.fromCharCode(unicode);
  }

  /*
   * 검색 문자열을 파싱해서 SQL Query 조건 문자열을 만든다.
   * @param strSearch 검색 문자열
   * @return SQL Query 조건 문자열
   */
  static String makeQuery(String column, String strSearch){
    strSearch = strSearch == null ? "null" : strSearch.trim();

    var retQuery = new StringBuffer();

    int nChoPosition;
    int nNextChoPosition;
    int startUnicode;
    int endUnicode;

    int nQueryIndex = 0;

    var query = new StringBuffer();

    for( int nIndex = 0 ; nIndex < strSearch.length; nIndex++ ){
      nChoPosition = -1;
      nNextChoPosition = -1;
      startUnicode = -1;
      endUnicode = -1;

      if( strSearch.codeUnitAt(nIndex) == QUERY_DELIM )
        continue;

      if( nQueryIndex != 0 ){
        query.write(" AND ");
      }

      for( int nChoIndex = 0 ; nChoIndex < INITIAL_SOUND_LIST.length ; nChoIndex++ ){
        if( strSearch[nIndex] == INITIAL_SOUND_LIST[nChoIndex] ){
          nChoPosition = nChoIndex;
          nNextChoPosition = nChoPosition+1;
          for( ; nNextChoPosition < INITIAL_SOUND_SEARCH_LIST.length ; nNextChoPosition++ ){
            if( INITIAL_SOUND_SEARCH_LIST[nNextChoPosition] )
              break;
          }
          break;
        }
      }

      if( nChoPosition >= 0 ){ //초성이 있을 경우

        startUnicode = HANGUL_BEGIN_UNICODE + nChoPosition*HANGUL_CHO_UNIT;
        endUnicode = HANGUL_BEGIN_UNICODE + nNextChoPosition*HANGUL_CHO_UNIT;

      }
      else{
        int unicode = convertCharToUnicode(strSearch[nIndex]);
        if( unicode >= HANGUL_BEGIN_UNICODE && unicode <= HANGUL_END_UNICODE){
          int Jong = ((unicode-HANGUL_BEGIN_UNICODE)%HANGUL_CHO_UNIT)%HANGUL_JUNG_UNIT;

          if( Jong == 0 ){// 초성+중성으로 되어 있는 경우
            startUnicode = unicode;
            endUnicode = unicode+HANGUL_JUNG_UNIT;
          }
          else{
            startUnicode = unicode;
            endUnicode = unicode;
          }
        }
      }

      if( startUnicode > 0 && endUnicode > 0 ){
        if( startUnicode == endUnicode )
          query.write("substr($column,${nIndex+1},1)='${strSearch[nIndex]}'");
        else
          query.write("(substr($column,${nIndex+1},1)>='${convertUnicodeToChar(startUnicode)}' AND substr($column,${nIndex+1},1)<'${convertUnicodeToChar(endUnicode)}')");
      }
      else{
        if( isLowerCase(strSearch[nIndex])){ //영문 소문자
          query.write("(substr($column,${nIndex+1},1)='${strSearch[nIndex]}' OR substr($column,${nIndex+1},1)='${strSearch[nIndex].toUpperCase()}')");
        }
        else if(isUpperCase(strSearch[nIndex])){ //영문 대문자
          query.write("(substr($column,${nIndex+1},1)='${strSearch[nIndex]}' OR substr($column,${nIndex+1},1)='${strSearch[nIndex].toLowerCase()}')");
        }
        else //기타 문자
          query.write("substr($column,${nIndex+1},1)='${strSearch[nIndex]}'");
      }

      nQueryIndex++;
    }

    if(query.length > 0 && strSearch != null && strSearch.trim().length > 0) {
      retQuery.write("(${query.toString()})");

      if(strSearch.indexOf(" ") != -1) {
        // 공백 구분 단어에 대해 단어 모두 포함 검색
        List<String> tokens = strSearch.split(" ");
        retQuery.write(" OR (");
        for(int i=0, isize=tokens.length; i<isize; i++) {
          String token = tokens[i];
          if(i != 0) {
            retQuery.write(" AND ");
          }
          retQuery.write("$column like '%"+token+"%'");
        }
        retQuery.write(")");
      } else {
        // LIKE 검색 추가
        retQuery.write(" OR $column like '%"+strSearch+"%'");
      }
    } else {
      retQuery.write(query.toString());
    }
    return retQuery.toString();
  }

  static bool isUpperCase(String string) {
    if (string == null) {
      return false;
    }
    if (string.isEmpty) {
      return false;
    }
    if (string.trimLeft().isEmpty) {
      return false;
    }
    String firstLetter = string.trimLeft().substring(0, 1);
    if (double.tryParse(firstLetter) != null) {
      return false;
    }
    return firstLetter.toUpperCase() == string.substring(0, 1);
  }

  static bool isLowerCase(String string) {
    if (string == null) {
      return false;
    }
    if (string.isEmpty) {
      return false;
    }
    if (string.trimLeft().isEmpty) {
      return false;
    }
    String firstLetter = string.trimLeft().substring(0, 1);
    if (double.tryParse(firstLetter) != null) {
      return false;
    }
    return firstLetter.toLowerCase() == string.substring(0, 1);
  }

}