//
//  VoiceCallView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 12/5/2023.
//

import SwiftUI

struct VoiceCallView: View {
    let name : String
    let path : URL
    @StateObject private var hub = BenHubState.shared
    @State private var counter : Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @EnvironmentObject private var videoCallVM : VideoCallViewModel
    var body: some View {
        ZStack{
            AsyncImage(url: path, content: {img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
                    .edgesIgnoringSafeArea(.all)
                    .overlay{
                        BlurView(style: .systemThinMaterialDark).edgesIgnoringSafeArea(.all)
                    }
                
            }, placeholder: {
                ProgressView()
                    .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
            })
            
            VStack(spacing:12){
                
                HStack{
                    Button(action:{
                        withAnimation{
                            self.videoCallVM.isIncomingCall = false
                        }
                    }){
                        Image(systemName: "chevron.down")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .scaleEffect(1.3)
                    }
                    
                    Spacer()
                }
                AsyncImage(url: path, content: {img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:120,height: 120)
                        .clipShape(Circle())
                    
                    
                    
                }, placeholder: {
                    ProgressView()
                        .frame(width:120,height: 120)
                    
                })
                
                Text(name)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                if self.videoCallVM.callState == .Connected {
                    //TODO Start a timer
                    Text(timeString(time: TimeInterval(self.counter)))
                        .foregroundColor(.white)
                        .font(.subheadline)
                }else {
                    Image(systemName: "ellipsis")
                        .imageScale(.medium)
                        .foregroundColor(.white)
                }
                
                Spacer()
//                
                if self.videoCallVM.callState == .Incoming {
                    self.IncomingCall()
                }else {
                    self.Connected()
                }
            }
            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
            .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
            .padding(.bottom)
            .padding(.horizontal)
            .background{
                ZStack{
                    RTCVideoView(track: self.videoCallVM.remoteVideoTrack,webClient: videoCallVM.webRTCClient, isRemote: true, isVoice: true,refershTrack: self.$videoCallVM.refershLocalTrack).frame(width: 0, height: 0)
                    
                    RTCVideoView(track: self.videoCallVM.localVideoTrack,webClient: videoCallVM.webRTCClient, isRemote: false, isVoice: true,refershTrack: self.$videoCallVM.refershRemoteTrack).frame(width: 0, height: 0)
                  
                }
                .hidden()
            }.onReceive(self.timer){ _ in
                if self.videoCallVM.callState != .Connected {
                    return
                }
                self.counter += 1
            }
            .onChange(of: self.videoCallVM.callState){ state in
//                print("State Changed : \(state)")
                if state == .Ended { //TODO: the connection is disconnected -> Reset all the and disconnect
                    DispatchQueue.main.async {
                        self.videoCallVM.isIncomingCall = false
                        self.videoCallVM.DisConnect()
                        hub.AlertMessage(sysImg: "", message: "Voice Call Ended")
                    }
                }
            }

            
        }
    }
    @ViewBuilder
    private func IncomingCall() -> some View {
        HStack{
//            Spacer()
            VStack{
                Button(action:{
                    //TODO: Send answer
                    self.videoCallVM.callState = .Connecting
                    self.videoCallVM.sendAnswer(type: .Voice)
                }){
                    Circle()
                        .fill(.green)
                        .frame(width: 70,height: 70)
                        .overlay{
                            Image(systemName: "phone.fill")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                }
                
                Text("Accept")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            Spacer()
            
            VStack{
                Button(action:{
                    //Send a Bye signal
                    DispatchQueue.main.async { //TODO: Send disconnected signal and Disconnect and reset all RTC
                        self.videoCallVM.sendDisconnect()
                        self.videoCallVM.DisConnect()
                        self.videoCallVM.isIncomingCall = false
                    }
                 
                }){
                    Circle()
                        .fill(.red)
                        .frame(width: 70,height: 70)
                        .overlay{
                            Image(systemName: "phone.down.fill")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                }
                Text("Reject")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)


//            Spacer()
        }
        .padding(.horizontal,20)
        .padding(.vertical)
    }
    
    @ViewBuilder
    private func Connected() -> some View {
        HStack{
            Button(action:{
                if self.videoCallVM.isAudioOn {
                    self.videoCallVM.mute()
                }else {
                    self.videoCallVM.unmute()
                }
            }){
                VStack(spacing:5){
                    Image(systemName: self.videoCallVM.isAudioOn ? "mic.slash.fill" : "mic.fill")
                        .imageScale(.large)
                        .scaleEffect(1.1)
                    
                    Text("Mute")
                        .font(.caption)
                }
                .foregroundColor(.white)
            }
            Spacer()
            Button(action:{
                DispatchQueue.main.async {
                    //TODO: disconnect and reset and send the signal
                    print("Disconnected????")
                    self.videoCallVM.sendDisconnect()
                    self.videoCallVM.DisConnect()
                    self.videoCallVM.isIncomingCall = false                }
            }){
                Circle()
                    .fill(.red)
                    .frame(width: 70,height: 70)
                    .overlay{
                        Image(systemName: "phone.down.fill")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
            }
            
            Spacer()
            Button(action:{
                if self.videoCallVM.isSpeakerOn {
                    self.videoCallVM.speakerOff()
                }else {
                    self.videoCallVM.speakerOn()
                }
            }){
                VStack(spacing:5){
                    Image(systemName: self.videoCallVM.isSpeakerOn ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .imageScale(.large)
                        .scaleEffect(1.1)
                    
                    Text("Speaker \noff")
                        .font(.caption)
                }
                .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
    }
    
    func timeString(time: TimeInterval) -> String {
        let hour = Int(time) / 3600
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        
        // return formated string
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }

}



extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = style
    return formatter.string(from: self) ?? ""
  }
}
