import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/uris.dart';

class ChainNetType {
  static ChainNetType ethereum = ChainNetType("ethereum", "Ethereum", 1, Assets.img.ico_36_ethereum,
       [Uris.blockcahin.ethereum]);
  static ChainNetType rinkeby = ChainNetType("rinkeby", "Rinkeby", 4, Assets.img.ico_36_ethereum,
       [Uris.blockcahin.rinkeby]);
  static ChainNetType goerli = ChainNetType("goerli", "Goerli", 5, Assets.img.ico_36_ethereum,
       [Uris.blockcahin.goerli]);
  static ChainNetType klaytn = ChainNetType("klaytn", "Klaytn", 8217, Assets.img.ico_36_klaytn,
       [Uris.blockcahin.klatyn]);
  static ChainNetType baobab = ChainNetType("baobab", "Baobab", 1001, Assets.img.ico_36_klaytn,
       [Uris.blockcahin.klatyn]);
  static ChainNetType bora = ChainNetType("bora", "Bora", 77001, Assets.img.ico_36_klaytn,
       [Uris.blockcahin.bora]);
  static ChainNetType polygon = ChainNetType("polygon", "Polygon", 137, Assets.img.ico_36_ethereum,
       [Uris.blockcahin.polygon]);
  static ChainNetType tokenSquare = ChainNetType("tokenSquare", "tokenSquare", -1, "",
       []);
  static ChainNetType ai = ChainNetType("ai", "ai", -1, "",
       []);
  static ChainNetType user = ChainNetType("user", "user", -1, "",
       []);
/*  static ChainNetType solana = ChainNetType("solana", "Solana", 137, Assets.img.ico_36_ethereum,
      CurrencyParams(name: 'SOL', symbol: 'SOL', decimals: 18), [Uris.blockcahin.polygon]);*/

  static Map<String, ChainNetType> values = {
    ethereum.name: ethereum,
    rinkeby.name: rinkeby,
    goerli.name: goerli,
    klaytn.name: klaytn,
    baobab.name: baobab,
    bora.name: bora,
    polygon.name: polygon,
    tokenSquare.name: tokenSquare,
    ai.name: ai,
    user.name: user
    // solana.name: solana
  };

//-------------------------//
  final String name;
  final String fullName;
  final int chainId;
  final String chainIcon;
  final List<String> rpcUrls;

  const ChainNetType(this.name, this.fullName, this.chainId, this.chainIcon, this.rpcUrls);
  static ChainNetType? byChainId(int chainId) {
    for(var chain in values.values) {
      if(chain.chainId == chainId)
        return chain;
    }
    return null;
  }
}
