//
//  PlaySound.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 17.09.2024.
//

import AudioToolbox
import Foundation

import AVFoundation

var audioPlayer: AVAudioPlayer?

func playSound(name: String) {
    guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
        return
    }
    let url = URL(fileURLWithPath: path)
    do {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()
    } catch {
        print("Error playing sound: \(error)")
    }
}
