//
//  VideoCall.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 14/5/2023.
//

import SwiftUI

struct VideoCallView: View {
    @StateObject private var hub = BenHubState.shared
    @EnvironmentObject var videoCallVM : RTCViewModel
    @EnvironmentObject private var userVM : UserViewModel
    let name : String
    let path : URL
    
    var body: some View {
        ZStack(alignment:.top){
            AsyncImage(url: path, content: {img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(){
                        BlurView(style: .systemThinMaterialDark).edgesIgnoringSafeArea(.all)
                    }
                    .overlay(alignment:.top){
                        ZStack{
                            if self.videoCallVM.callState == .Incoming {
                                incomingCallView()
                              
                            }else {
                                videoCallingView()
                            }
                        }
                       
                    }
            }, placeholder: {
                ProgressView()
                    .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
            })
            .zIndex(-1)


        }
        .edgesIgnoringSafeArea(.all)
        .overlay(alignment: .top){
            HStack(alignment: .top){
                Button(action:{
                    DispatchQueue.main.async {
                        withAnimation(){
                            self.videoCallVM.isMinimized = true
                        }
                    }
                }){
                    Image(systemName: "chevron.down")
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .padding(5)
                }
                .padding(5)
                .background(BlurView().clipShape(Circle()))

                Spacer()
//
                if self.videoCallVM.callState == .Connected {
                    VStack{
                        AsyncImage(url: path, content: {img in
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width:30,height: 30)
                                .clipShape(Circle())



                        }, placeholder: {
                            ProgressView()
                                .frame(width:120,height: 120)

                        })

                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .padding(.horizontal)
//            .padding()
            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
            .onChange(of: self.videoCallVM.callState){ state in
                if state == .Ended { //TODO: the connection is disconnected -> Reset all the and disconnect
                    SoundManager.shared.stopPlaying()
                    withAnimation{
                        self.videoCallVM.isIncomingCall = false
                    }
                    self.videoCallVM.DisConnect()
                    playEndCallSoundEffect()
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
        .animation(.linear)
        

    }
    private func playEndCallSoundEffect(){
        guard let url = Bundle.main.url(forResource: "endcall", withExtension: ".mp3") else {
            return
        }
        SoundManager.shared.playSound(url: url,repeatTime: 0)
    }
    
    @ViewBuilder
    private func videoCallingView() -> some View {
        VStack{
            RTCVideoView(webClient: videoCallVM.webRTCClient, isRemote: true, isVoice: false,refershTrack: Binding<Bool>(get: {return self.videoCallVM.refershRemoteTrack},
                                                                                                                                                                  set: { p in self.videoCallVM.refershRemoteTrack = p}))
            //            .edgesIgnoringSafeArea(.all)

            .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
        }
        .overlay(alignment:.bottomLeading){
            VStack(alignment:.trailing){
                RTCVideoView(webClient: videoCallVM.webRTCClient, isRemote: false, isVoice: false,refershTrack: Binding<Bool>(get: {return self.videoCallVM.refershLocalTrack},
                                                                                                                                                      set: { p in self.videoCallVM.refershLocalTrack = p}))
                .frame(width: 150, height: 220)
                .cornerRadius(25)
                .padding()
                .background(BlurView().cornerRadius(25).padding())
                callingBtn()
            }
            .padding(.bottom,30)
           
        }
        
    }
    
    @ViewBuilder
    private func callingBtn() -> some View {
        HStack{
            Button(action: {
                if self.videoCallVM.isAudioOn {
                    self.videoCallVM.mute()
                }else {
                    self.videoCallVM.unmute()
                }
            }){
                Image(systemName: self.videoCallVM.isAudioOn ? "mic.slash.fill" : "mic.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding()
                    .background{
                        Color.blue.clipShape(Circle())
                    }
           
            }
            Spacer()
            Button(action: {
                if self.videoCallVM.isSpeakerOn {
                    self.videoCallVM.speakerOff()
                }else {
                    self.videoCallVM.speakerOn()
                }
            }){
                Image(systemName: self.videoCallVM.isSpeakerOn ? "speaker.slash" :  "speaker.wave.3.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding()
                    .background{
                        Color.blue.clipShape(Circle())
                    }

            }
            Spacer()
            Button(action: {
                DispatchQueue.main.async {
                    //TODO: disconnect and reset and send the signal
                    self.videoCallVM.sendDisconnect()
                    self.videoCallVM.DisConnect()
                    withAnimation{
                        self.videoCallVM.isIncomingCall = false
                    }
                    self.sendCallingMessage(message: "Ended the video call.")
                }
            }){
                Image(systemName: "phone.down.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding(30)
                    .background{
                        Circle()
                            .fill(.red)
                    }
            }
            Spacer()
            Button(action: {
                if self.videoCallVM.isVideoOn {
                    self.videoCallVM.videoOff()
                }else {
                    self.videoCallVM.videoOn()
                }
            }){
                Image(systemName: self.videoCallVM.isVideoOn ? "video.slash" : "video.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding()
                    .background{
                        Color.blue.clipShape(Circle())
                    }

            }
            Spacer()
            Button(action: {
                self.videoCallVM.changeCamera()
            }){
                Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding()
                    .background{
                        Color.blue.clipShape(Circle())
                    }

            }
            
        }.padding(.horizontal)
    }
    
    @ViewBuilder
    private func incomingCallView() -> some View {
        VStack{
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

            VStack(spacing:5){
                Text("Video Calling")
                    .foregroundColor(.white)
                    .font(.footnote)
                HStack{
                    DotView() // 1.
                    DotView(delay: 0.2) // 2.
                    DotView(delay: 0.4) // 3.
                }
                .padding(.vertical,8)
            }
            .padding(.vertical,5)
            Spacer()
            IncomingCall()

        }
        .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
        .padding(.top,15)
        .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .padding(.bottom)
        .padding(.horizontal)
//        .edgesIgnoringSafeArea(.all)
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
                        withAnimation{
                            self.videoCallVM.isIncomingCall = false
                        }
                        self.sendCallingMessage(message: "Ended the video call.")
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
    }
    
    
    private func sendCallingMessage(message : String){
        if message.isEmpty {
            return
        }
        
        guard let toUserId = self.videoCallVM.toUserUUID else{
            print("userId is empty")
            return
        }
        
        let msgID = UUID().uuidString
        
        let msg = WSMessage(
            messageID:msgID,
            replyMessageID: nil,
            avatar: self.userVM.profile!.avatar,
            fromUserName: self.userVM.profile!.name,
            fromUUID: self.userVM.profile!.uuid,
            toUUID: toUserId,
            content: message,
            contentType: ContentType.TEXT.rawValue,
            eventType: EventType.MESSAGE.rawValue,
            messageType: MessageType.Signal.rawValue,
            urlPath: nil,
            fileName: nil,
            fileSize: nil,
            contentAvailableTime: nil,
            contentUUID: nil,
            contentUserName: nil,
            contentUserAvatar: nil,
            contentUserUUID: nil)
        Websocket.shared.handleMessage(event:.send,msg: msg)
        
        
        Task {
            await Websocket.shared.checkMessage(messageID: msgID)
        }
    }
  
}
