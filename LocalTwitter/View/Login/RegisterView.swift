//
//  RegisterView.swift
//  LocalTwitter
//
//  Created by Erik on 22.01.2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct RegisterView: View {
    //MARK: - User Detail
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    //MARK: - View Properties
    @Environment(\.dismiss) var dismiss
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    //MARK: - UserDefaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        VStack(spacing: 10){
            Text("Lets Register\nAccount")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Hello user, have a wonderful journey")
                .font(.title3)
                .hAlign(.leading)
            
            //MARK: - For Smaller Size Optimization
            ViewThatFits{
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
                
                HelperView()
            }
            
            //MARK: - Register Button
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                
                Button("Login Now"){
                    dismiss()
                }
                .foregroundColor(.black)
                .fontWeight(.bold)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            //MARK: - Extracting UIImage From PhotoItem
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else {return}
                        
                        await MainActor.run(body: {
                            userProfilePicData = imageData
                        })
                    } catch{}
                }
            }
        }
        //MARK: - Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    @ViewBuilder
    func HelperView()-> some View{
        VStack(spacing: 12) {
            ZStack{
                if let userProfilePicData, let image = UIImage(data: userProfilePicData){
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top,25)

            TextField("username", text: $userName)
                .textContentType(.username)
                .border(1, .gray.opacity(0.5))
            
            TextField("email", text: $emailID)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            SecureField("password", text: $password)
                .textContentType(.password)
                .border(1, .gray.opacity(0.5))
            
            TextField("About You", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("Bio Link (Optional)", text: $userBioLink)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            Button(action: registerUser){
                Text("Sign in")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
                    .padding(.top, 10)
            }
            .disabledWithOpacity(userName == "" || userBio == "" || emailID == "" || password == "" || userProfilePicData == nil)
        }
    }
    
    func registerUser(){
        isLoading = true
        closeKeyboard()
        Task{
            do{
                //Creating FireBase Account
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                //Uploading Profile Photo Into Firebase Storage
                guard let userUID = Auth.auth().currentUser?.uid else {return}
                guard let imageData = userProfilePicData else {return}
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                try await storageRef.putDataAsync(imageData)
                //Downloading Photot URL
                let downloadURL = try await storageRef.downloadURL()
                //Creating a User FireStore Object
                let user = User(username: userName, userBio: userBio, userBioLink: userBioLink, userUID: userUID, userEmail: emailID, userProfileURL: downloadURL)
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: { error in
                    if error == nil {
                        print("Saved Successfully")
                        userNameStored = userName
                        self.userUID = userUID
                        profileURL = downloadURL
                        logStatus = true
                    }
                })
            } catch {
                await setError(error)
            }
        }
    }
    
    //MARK: - Displaying Errors VIA Alerts
    func setError(_ error: Error)async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
