//
//  SoundPlayerView.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 09.09.2024.
//

import Foundation
import AVFoundation

class SoundPlayerView {
    private var soundPlayer: AVAudioPlayer?

    // Функция для воспроизведения звука
    func playSound(fileName: String, fileType: String) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: fileType) {
            do {
                // Инициализация аудиоплеера с файлом
                soundPlayer = try AVAudioPlayer(contentsOf: url)
                soundPlayer?.play() // Запуск воспроизведения
            } catch {
                print("Ошибка воспроизведения звука: \(error.localizedDescription)")
            }
        } else {
            print("Файл не найден: \(fileName).\(fileType)")
        }
    }
}
