//
//  SessionDetailView.swift
//  big_project_c_admin_ipados
//
//  Created by TEDDY on 12/27/22.
//

import SwiftUI
import VisionKit

struct SessionDetailView: View {
    @State private var showCameraScannerView = false
    @State private var isDeviceCapacity = false
    @State private var showDeviceNotCapacityAlert = false
//    @State private var scanIdResult : String = ""
//    @State private var scanUserUidResult : String = ""
//    @State private var scanUserNickNameResult : String = ""
    @ObservedObject var seminarInfo: SeminarStore
    @EnvironmentObject var attendanceStore : AttendanceStore
//    @ObservedObject var questionInfo: QuestionStore

//    @Binding var seminarList: Seminar
    
    @Binding var seminarId: Seminar.ID?
    @State private var clickedEditButton: Bool = false
    @State private var clickedQRButton: Bool = false
    
    var selectedContent: Seminar? {
        get {
            for sample in seminarInfo.seminarList {
                if sample.id == seminarId {
                    return sample
                }
            }
            return nil
        }
    }

    @StateObject var questionStore: QuestionStore = QuestionStore()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if selectedContent == nil {
                    Image("LoginLogo")
                        .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
                }
                else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(selectedContent?.name ?? "")
                                .font(.title)
                                .fontWeight(.bold)
                            HStack {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text(selectedContent?.createdDate ?? "")
                                        .font(.subheadline)
                                        .padding(.trailing, 5)
                                    Image(systemName: "mappin.and.ellipse")
                                    Text(selectedContent?.location ?? "")
                                        .font(.subheadline)
                                }
                                
                                Spacer()
                                
                                HStack {
                                    
                                        Button {
                                            // TODO: 내용 수정 기능 구현
                                            clickedEditButton = true
                                        } label: {
                                            Text("세미나 내용 수정하기")
                                                .frame(width: 150)
                                                .padding(12)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color.white)
                                                .background(Color.accentColor)
                                                .cornerRadius(15)
                                        }
                                        .fullScreenCover(isPresented: $clickedEditButton) {
//                                            EditSessionView(seminarInfo: seminarInfo, selectedContent: selectedContent)
                                            EditTestView(seminarInfo: seminarInfo, seminarID: selectedContent?.id ?? "")
                                        }
                                    
                                    
                                    Button {
                                        // TODO: QR코드 연결
                                        if isDeviceCapacity {
                                            self.showCameraScannerView = true
                                        } else {
                                            self.showDeviceNotCapacityAlert = true
                                        }
                                    } label: {
                                        Text("QR코드")
                                            .frame(width: 150)
                                            .padding(12)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.white)
                                            .background(Color.accentColor)
                                            .cornerRadius(15)
                                    }

                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 20)
                            

                            // MARK: -View : Q&A 리스트 관리
                            Text("받은 Q&A")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            List(questionStore.questionList, id:\.self) { question in
                                Text(question.question)
                                    .padding()
                                    .listRowBackground(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.secondary.opacity(0.15))
                                            .foregroundColor(.white)
                                            .padding(
                                                EdgeInsets(
                                                    top: 10,
                                                    leading: 0,
                                                    bottom: 10,
                                                    trailing: 0
                                                )
                                            )

                                    )
                                    .listRowSeparator(.hidden)
                            }
                            .scrollContentBackground(.hidden)
                            .listStyle(InsetGroupedListStyle())
                            .padding(.leading, -13)
                            
                            

                            Spacer()
                        }
                        .padding(.leading, 40)
                        
                        
                        // MARK: -View : 오른쪽 사이드 유저 리스트
        //                SessionDetailUserList(seminarID: seminarId)
                        SessionDetailUserList(selectedContent: selectedContent)
                            .frame(width: geo.size.width/4)
                            .padding(.trailing, 20)
                    }
                }
            }
            .sheet(isPresented: $showCameraScannerView) {
                CameraScanner(startScanning: $showCameraScannerView, seminarID: selectedContent?.id ?? "")
                        }
            .alert("스캐너 사용불가", isPresented: $showDeviceNotCapacityAlert, actions: {})
        }
        .onAppear {
//            print("온어피어")
//            print("세미나 아이디", selectedContent?.id)
            isDeviceCapacity = (DataScannerViewController.isSupported && DataScannerViewController.isAvailable)
            questionStore.fetchQuestion(seminarID: seminarId ?? "")
        }
        .onChange(of:seminarId) { newValue in
            questionStore.fetchQuestion(seminarID: seminarId ?? "")
        }
    }
}


//struct SessionDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionDetailView()
//    }
//}
