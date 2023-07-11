import '../../constants/chain_net_type.dart';

enum TokenType {
  bora, tbora
}

class Web3Sign {
  final String message;
  final String address;
  final String signature;
  final String walletType;
  final ChainNetType blockchainNetType;

  Web3Sign(this.message, this.address, this.signature, this.walletType, this.blockchainNetType);
  Web3Sign.empty():message='', address='', signature='', walletType='', blockchainNetType=ChainNetType.ethereum;
  Map<String, dynamic> toMap() => {
    'message': message,
    'chainId': blockchainNetType.chainId,
    'address': address,
    'signature': signature,
    'walletType': walletType,
    'blockchainNetType': blockchainNetType.name
  };
}