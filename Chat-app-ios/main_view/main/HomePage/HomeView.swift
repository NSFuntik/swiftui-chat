//
//  HomeView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 19/2/2023.
//

import SwiftUI
import PhotosUI

struct MenuTag : Identifiable {
    let id : Int
    let navBarTitle : String
    let toolbarIcon : String
}

let tags : [MenuTag] = [
    MenuTag(id: 0, navBarTitle: "Messages",toolbarIcon: "plus.circle"),
    MenuTag(id: 1, navBarTitle: "Calls",toolbarIcon: "video.fill"),
    MenuTag(id: 2,navBarTitle: "Friends",toolbarIcon: ""),
]


struct HomeView: View {
    
    @EnvironmentObject private var storyModel : StoryViewModel
    @EnvironmentObject private var userModel : UserViewModel
    @EnvironmentObject private var UDM : UserDataModel
    @EnvironmentObject private var userStory : UserStoryViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var videoCallVM = VideoCallViewModel()
    @StateObject var hub = BenHubState.shared
    @State private var index = 0
    @State private var search = ""
    @State private var isShowSheet = false
    @State private var isActive = true
    @Binding var isShowMenu : Bool
    @Binding var menuTab : Int
    @Binding var isAddStory : Bool
    @State private var selectedItem : PhotosPickerItem? = nil
    
    @State private var isShowProfile : Bool = false
    var body: some View {
        ZStack{
//            TabView(selection:$index){
                Message(isActive: $isActive,isAddStory:$isAddStory)
                    .environmentObject(userModel)
                    .environmentObject(UDM)
                    .environmentObject(storyModel)
                    .environmentObject(userStory)
                    .environmentObject(videoCallVM)
//                    .tabItem{
//                        VStack{
//                            Image(systemName: "message.fill")
//                            Text("Messages")
//                        }
//                    }
//                    .tag(0)
//                    .badge(99)
                
//
//                CallView()
//                    .tabItem{
//                        VStack{
//                            Image(systemName: "phone.fill")
//                            Text("Calls")
//                        }
//
//                    }
//                    .tag(1)
//                    .environmentObject(userModel)
//
//                //            NavigationStack{
//                FriendContent()
//                    .tabItem{
//                        VStack{
//                            Image(systemName: "person.2")
//                            Text("Friends")
//                        }
//
//                    }
//                    .tag(2)
//                    .badge(5)
//                    .environmentObject(userModel)
//
                
                
//            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .principal){
                    Text(tags[self.index].navBarTitle)
                        .bold()
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action:{
                        withAnimation{
                            self.isShowMenu = true
                        }
                    }){
                        Image(systemName: "list.bullet")
                            .imageScale(.large)
                            .foregroundColor(Color.green)
                            .bold()
                    }
                    
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action:{
                        withAnimation{
                            self.isShowSheet.toggle()
                        }
                    }){
                        Image(systemName: tags[self.index].toolbarIcon)
                            .imageScale(.large)
                            .foregroundColor(Color.green)
                            .bold()
                    }
                    
                    
                }
                
            }
//            .searchable(text: $search,placement: .navigationBarDrawer,prompt: "search")
        }
        .onAppear{
            self.videoCallVM.start()
        }
        .sheet(isPresented: $isShowSheet){
            AddContent(isAddContent: $isShowSheet)
                .environmentObject(UDM)
                .environmentObject(userModel)
        }
        .fullScreenCover(isPresented: $isAddStory){
            StoryPhototView(isAddStory: $isAddStory)
                .environmentObject(userModel)
                .environmentObject(userStory)
        }
        .fullScreenCover(isPresented: $storyModel.isShowStory){
            StoryOtherView()
                .environmentObject(storyModel)
                .onDisappear{
                    self.storyModel.currentStory = 0
                }
        }
        .fullScreenCover(isPresented: $userStory.isShowStory){
            StoryUserView()
                .environmentObject(userModel)
                .environmentObject(userStory)
        }
//        .wait(isLoading: $hub.isWaiting){
//            BenHubLoadingView(message: hub.message)
//        }
//        .alert(isAlert: $hub.isPresented){
//            switch hub.type{
//            case .normal,.system:
//                BenHubAlertView(message: hub.message, sysImg: hub.sysImg)
//            case .messge:
//                BenHubAlertWithMessage( message: hub.message,info: hub.info!)
//            }
//        }
      
//        .accentColor(.green)
        
    }
    

}
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView(isShowMenu: .constant(false), menuTab: .constant(0))
//    }
//}
