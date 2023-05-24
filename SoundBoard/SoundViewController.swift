//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by MacBook Pro on 24/05/23.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var labelDuracionTotal: UILabel!
    @IBOutlet weak var labelTiempoReproduccion: UILabel!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reproducirButton.isEnabled = false
        configurarGrabacion()
        agregarButton.isEnabled = false
    }
    
    func configurarGrabacion() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath,"audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("*******************")
            print(audioURL!)
            print("*******************")
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
            
        } catch let error as NSError{
            print(error)
        }
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            //detener la grabacion
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        }else{
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio?.delegate = self
            let duration = Int(reproducirAudio!.duration)
                
                // Convierte la duración total en minutos y segundos
                let minutesDuration = duration / 60
                let secondsDuration = duration % 60
            
            // Actualiza el label con la duración total
            labelDuracionTotal.text = String(format: "%02d:%02d", minutesDuration, secondsDuration)
            
            reproducirAudio!.play()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updatePlaybackTime), userInfo: nil, repeats: true)
        
            print("Reproduciendo")
        } catch {}
        
    }
    
    @objc func updatePlaybackTime() {
        guard let reproducirAudio = reproducirAudio else {
            return
        }
        
        let currentTime = reproducirAudio.currentTime
        let minutes = Int(currentTime / 60)
        let seconds = Int(currentTime.truncatingRemainder(dividingBy: 60))
        
        // Actualiza el label con el tiempo de reproducción
        labelTiempoReproduccion.text = String(format: "%02d:%02d", minutes, seconds)

    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        timer = nil
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.duration = Double(reproducirAudio!.duration)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }

}
