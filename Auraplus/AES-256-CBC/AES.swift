import Foundation
import CommonCrypto

public class AESHelper {
    public static let shared = AESHelper()

    private init() {}

    public let defaultKey = "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"
    public let defaultIV  = "000102030405060708090a0b0c0d0e0f"

    public func encrypt(message: String, keyHex: String? = nil, ivHex: String? = nil) -> String? {
        let keyHex = keyHex ?? defaultKey
        let ivHex = ivHex ?? defaultIV

        guard let keyData = Data(hexString: keyHex),
              let ivData = Data(hexString: ivHex),
              let dataToEncrypt = message.data(using: .utf8) else { return nil }

        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: dataToEncrypt.count + kCCBlockSizeAES128)

        let status = CCCrypt(CCOperation(kCCEncrypt),
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionPKCS7Padding),
                             [UInt8](keyData),
                             keyData.count,
                             [UInt8](ivData),
                             [UInt8](dataToEncrypt),
                             dataToEncrypt.count,
                             &outBytes,
                             outBytes.count,
                             &outLength)

        guard status == kCCSuccess else { return nil }
        return Data(bytes: outBytes, count: outLength).base64EncodedString()
    }

    public func decrypt(base64CipherText: String, keyHex: String? = nil, ivHex: String? = nil) -> String? {
        let keyHex = keyHex ?? defaultKey
        let ivHex = ivHex ?? defaultIV

        guard let cipherData = Data(base64Encoded: base64CipherText),
              let keyData = Data(hexString: keyHex),
              let ivData = Data(hexString: ivHex) else { return nil }

        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: cipherData.count + kCCBlockSizeAES128)

        let status = CCCrypt(CCOperation(kCCDecrypt),
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionPKCS7Padding),
                             [UInt8](keyData),
                             keyData.count,
                             [UInt8](ivData),
                             [UInt8](cipherData),
                             cipherData.count,
                             &outBytes,
                             outBytes.count,
                             &outLength)

        guard status == kCCSuccess else { return nil }
        return String(data: Data(bytes: outBytes, count: outLength), encoding: .utf8)
    }
}

// MARK: - Data Extension for Hex Conversion
public extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var index = hexString.startIndex
        for _ in 0..<len {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard nextIndex <= hexString.endIndex else { return nil }
            if let b = UInt8(hexString[index..<nextIndex], radix: 16) {
                data.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        self = data
    }
}
