//
//  AudioRecorderDelegateHandler.swift
//  Auraplus
//
//  Created by Hussnain on 22/6/25.
//

import Foundation
import AVFAudio

class AudioRecorderDelegateHandler: NSObject, AVAudioRecorderDelegate {
    var onFinish: ((Bool) -> Void)?
    var onError: ((Error?) -> Void)?

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        onFinish?(flag)
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        onError?(error)
    }
}
