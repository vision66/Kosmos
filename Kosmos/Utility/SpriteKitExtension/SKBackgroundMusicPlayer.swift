//
//  SKBackgroundMusicPlayer.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/9/14.
//  Copyright © 2018年 aceasy. All rights reserved.
//

import AVFoundation

/// 播放背景音乐,
/// 音量大小将会保存到UserDefaults["background music volume"]中, 是String类型
/// 音乐文件需要存放到[main.bundle]中的[background music]目录下, 并且是m4a类型
class SKBackgroundMusicPlayer {
    
    /// 播放器
    static let shared = SKBackgroundMusicPlayer()
    
    /// 音量
    private var currentVolume: Float = 0.5
    
    /// 正在运行中的播发器
    private var currentPlayer: AVAudioPlayer?
    
    /// 正在播放的声音文件名, 如果两次播放的相同, 就忽略第二次的
    private var currentMusic : URL?
    
    /// init
    private init() {
        
        if let value = UserDefaults.standard.string(forKey: "background music volume") {
            currentVolume = value.asFloat
        } else {
            currentVolume = 1.0
        }
        
        do {
            // 参考: https://www.jianshu.com/p/f7d2e6349139
            // AVAudioSessionCategoryAmbient: 当前App的播放声音可以和其他app播放的声音共存，当锁屏或按静音时停止。
            // AVAudioSessionModeDefault: 默认的模式，适用于所有的场景，可用于场景还原
            // AVAudioSessionCategoryOptionMixWithOthers: 适用于AVAudioSessionCategoryPlayAndRecord、AVAudioSessionCategoryPlayback、AVAudioSessionCategoryMultiRoute, 用于可以和其他app进行混音
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient, mode: AVAudioSession.Mode.default, policy: AVAudioSession.RouteSharingPolicy.default, options: AVAudioSession.CategoryOptions.mixWithOthers)
        } catch {
            KSLog("setCategory Error: \(error)")
        }
    }
    
    /// 开始播放
    func play(_ url: URL) {
        
        if currentMusic == url {
            return
        }
        
        do {
            currentPlayer = try AVAudioPlayer(contentsOf: url)
            currentPlayer?.numberOfLoops = -1
            currentPlayer?.prepareToPlay()
            currentPlayer?.volume = currentVolume
            currentPlayer?.play()
            
            currentMusic = url
        } catch {
            KSLog("SKBackgroundMusicPlayer error: [\(error)]")
        }
    }
    
    /// 停止播放
    func stop() {
        currentPlayer?.stop()
        currentMusic = nil
    }
    
    /// 调整音量
    var volume : Float {
        
        get {
            return currentVolume
        }
        
        set {
            currentVolume = newValue
            currentPlayer?.volume = newValue
            UserDefaults.standard.set(newValue, forKey: "background music volume")
        }
    }
}
