//
//  SKSoundEffect.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/9/14.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import AVFoundation

/// 播放音效. 这个类相当于一个AVAudioPlayer的管理类
class SKSoundEffect : NSObject, AVAudioPlayerDelegate {
    
    /// 单例模式
    static let shared = SKSoundEffect()
    
    /// 载入内存的元数据
    private var metadata = [String : Data]()
    
    /// 游戏音效音量
    private var currentVolume: Float = 1.0
    
    /// 正在运行的播放器
    private var currentPlayers = [AVAudioPlayer]()
    
    ///
    private var queue = DispatchQueue(label: "com.aceasy.soundeffect")
    
    /// init
    private override init() {
        super.init()
        if let value = UserDefaults.standard.string(forKey: "sound effect volume") {
            currentVolume = value.asFloat
        } else {
            currentVolume = 1.0
        }
    }
    
    /// 加载音效. sounds是一个字典, 它的key会作为play(_:)方法的参数
    func loadMetadata(_ sounds: [String : URL]) {
        
        for sound in sounds {
            
            do {
                metadata[sound.key] = try Data(contentsOf: sound.value)
            } catch {
                KSLog("load sound effect [\(sound.key)], load failed")
            }
        }
    }
    
    /// 播放音效
    func play(_ sound: String) {
        
        queue.async {
            
            guard let data = self.metadata[sound] else {
                KSLog("play sound effect [\(sound)], not find")
                return
            }
            
            self.currentPlayers.removeAll(where: { $0.isPlaying == false })
            
            let player : AVAudioPlayer
            do {
                player = try AVAudioPlayer(data: data)
            } catch {
                KSLog("play sound effect [\(sound)], create player failed")
                return
            }
            
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.volume = self.currentVolume
            player.play()
            
            self.currentPlayers.append(player)
        }
    }
    
    /// 调整音量
    var volume : Float {
        
        get {
            return currentVolume
        }
        
        set {
            currentVolume = newValue
            UserDefaults.standard.set(newValue, forKey: "sound effect volume")
        }
    }
}
