//
//  DeliFactory.swift
//  Auto generated code.
//

import Crashlytics
import DeepLinkKit
import Deli
import Fabric
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import Foundation
import RealmSwift
import RxSwift
import UIKit
import Umbrella

final class DeliFactory: ModuleFactory {
    override func load(context: AppContext) {
        register(
            AddTodoViewController.self,
            resolver: {
                let _0 = context.get(AddTodoViewReactor.self, qualifier: "")!
                return AddTodoViewController(_0)
            },
            qualifier: "",
            scope: .weak
        )
        register(
            AddTodoViewReactor.self,
            resolver: {
                let _0 = context.get(TodoService.self, qualifier: "")!
                let _1 = context.get(ToastService.self, qualifier: "")!
                return AddTodoViewReactor(_0, _1)
            },
            qualifier: "",
            scope: .prototype
        )
        register(
            AppAnalytics.self,
            resolver: {
                let parent = context.get(AnalyticsConfiguration.self, qualifier: "")!
                return parent.analytics() as AnyObject
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            AnalyticsConfiguration.self,
            resolver: {
                return AnalyticsConfiguration()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            Fabric.self,
            resolver: {
                let parent = context.get(FabricConfiguration.self, qualifier: "")!
                return parent.fabric() as AnyObject
            },
            qualifier: "",
            scope: .always
        )
        register(
            FabricConfiguration.self,
            resolver: {
                return FabricConfiguration()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            FirebaseAuthServiceImpl.self,
            resolver: {
                let _0 = context.get(Auth.self, qualifier: "")!
                return FirebaseAuthServiceImpl(_0)
            },
            qualifier: "",
            scope: .singleton
        ).link(AuthService.self)
        register(
            FirebaseApp.self,
            resolver: {
                let parent = context.get(FirebaseConfiguration.self, qualifier: "")!
                return parent.firebase() as AnyObject
            },
            qualifier: "",
            scope: .always
        )
        register(
            Auth.self,
            resolver: {
                let parent = context.get(FirebaseConfiguration.self, qualifier: "")!
                return parent.auth() as AnyObject
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            Database.self,
            resolver: {
                let parent = context.get(FirebaseConfiguration.self, qualifier: "")!
                return parent.database() as AnyObject
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            DatabaseReference.self,
            resolver: {
                let parent = context.get(FirebaseConfiguration.self, qualifier: "")!
                return parent.todoTable() as AnyObject
            },
            qualifier: "todo",
            scope: .weak
        )
        register(
            DatabaseReference.self,
            resolver: {
                let parent = context.get(FirebaseConfiguration.self, qualifier: "")!
                return parent.userTable() as AnyObject
            },
            qualifier: "user",
            scope: .weak
        )
        register(
            FirebaseConfiguration.self,
            resolver: {
                return FirebaseConfiguration()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            FirebaseTodoRepositoryImpl.self,
            resolver: {
                let _0 = context.get(DatabaseReference.self, qualifier: "todo")!
                return FirebaseTodoRepositoryImpl(todo: _0)
            },
            qualifier: "remote",
            scope: .singleton
        ).link(TodoRepository.self)
        register(
            LoginViewController.self,
            resolver: {
                let _0 = context.get(LoginViewReactor.self, qualifier: "")!
                let _1 = context.get(AppAnalytics.self, qualifier: "")!
                let _2 = context.get(Navigator.self, qualifier: "")!
                return LoginViewController(_0, _1, _2)
            },
            qualifier: "",
            scope: .weak
        )
        register(
            LoginViewReactor.self,
            resolver: {
                let _0 = context.get(AuthService.self, qualifier: "")!
                let _1 = context.get(ToastService.self, qualifier: "")!
                let _2 = context.get(AppAnalytics.self, qualifier: "")!
                return LoginViewReactor(_0, _1, _2)
            },
            qualifier: "",
            scope: .prototype
        )
        register(
            MainNavigationViewController.self,
            resolver: {
                let _0 = context.get(MainNavigationViewReactor.self, qualifier: "")!
                let _1 = context.get(AppAnalytics.self, qualifier: "")!
                return MainNavigationViewController(_0, _1)
            },
            qualifier: "",
            scope: .weak
        )
        register(
            MainNavigationViewReactor.self,
            resolver: {
                return MainNavigationViewReactor()
            },
            qualifier: "",
            scope: .prototype
        )
        registerFactory(
            MoreCellReactor.self,
            resolver: { payload in
                
                return MoreCellReactor(payload: payload as! MoreCellPayload)
            },
            qualifier: ""
        ).link(MoreCellReactor.self)
        register(
            MoreViewController.self,
            resolver: {
                let _0 = context.get(MoreViewReactor.self, qualifier: "")!
                let _1 = context.get(Navigator.self, qualifier: "")!
                let _2 = context.get(AppAnalytics.self, qualifier: "")!
                return MoreViewController(_0, _1, _2)
            },
            qualifier: "",
            scope: .weak
        )
        register(
            MoreViewReactor.self,
            resolver: {
                let _0 = context.get(AuthService.self, qualifier: "")!
                return MoreViewReactor(_0)
            },
            qualifier: "",
            scope: .prototype
        )
        register(
            DPLDeepLinkRouter.self,
            resolver: {
                let parent = context.get(NavigatorConfiguration.self, qualifier: "")!
                return parent.router() as AnyObject
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            NavigatorConfiguration.self,
            resolver: {
                return NavigatorConfiguration()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            NavigatorImpl.self,
            resolver: {
                let _0 = context.get(UIWindow.self, qualifier: "")!
                return NavigatorImpl(_0)
            },
            qualifier: "",
            scope: .singleton
        ).link(Navigator.self)
        register(
            Realm.self,
            resolver: {
                let parent = context.get(RealmConfiguration.self, qualifier: "")!
                return parent.database() as AnyObject
            },
            qualifier: "",
            scope: .always
        )
        register(
            RealmConfiguration.self,
            resolver: {
                return RealmConfiguration()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            RealmTodoRepositoryImpl.self,
            resolver: {
                let _0 = context.get(Realm.self, qualifier: "")!
                let _1 = context.get(SchedulerType.self, qualifier: "realm")!
                return RealmTodoRepositoryImpl(_0, realm: _1)
            },
            qualifier: "local",
            scope: .singleton
        ).link(TodoRepository.self)
        register(
            SchedulerType.self,
            resolver: {
                let parent = context.get(RxSchedulerConfiguration.self, qualifier: "")!
                return parent.realmScheduler() as AnyObject
            },
            qualifier: "realm",
            scope: .singleton
        )
        register(
            SchedulerType.self,
            resolver: {
                let parent = context.get(RxSchedulerConfiguration.self, qualifier: "")!
                return parent.syncScheduler() as AnyObject
            },
            qualifier: "sync",
            scope: .singleton
        )
        register(
            RxSchedulerConfiguration.self,
            resolver: {
                return RxSchedulerConfiguration()
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            SignUpViewController.self,
            resolver: {
                let _0 = context.get(SignUpViewReactor.self, qualifier: "")!
                let _1 = context.get(AppAnalytics.self, qualifier: "")!
                let _2 = context.get(Navigator.self, qualifier: "")!
                return SignUpViewController(_0, _1, _2)
            },
            qualifier: "",
            scope: .weak
        )
        register(
            SignUpViewReactor.self,
            resolver: {
                let _0 = context.get(AuthService.self, qualifier: "")!
                let _1 = context.get(ToastService.self, qualifier: "")!
                let _2 = context.get(AppAnalytics.self, qualifier: "")!
                return SignUpViewReactor(_0, _1, _2)
            },
            qualifier: "",
            scope: .prototype
        )
        register(
            SplashViewController.self,
            resolver: {
                let _0 = context.get(SplashViewReactor.self, qualifier: "")!
                let _1 = context.get(Navigator.self, qualifier: "")!
                return SplashViewController(_0, _1)
            },
            qualifier: "",
            scope: .weak
        )
        register(
            SplashViewReactor.self,
            resolver: {
                let _0 = context.get(AuthService.self, qualifier: "")!
                return SplashViewReactor(_0)
            },
            qualifier: "",
            scope: .prototype
        )
        register(
            ToastServiceImpl.self,
            resolver: {
                return ToastServiceImpl()
            },
            qualifier: "",
            scope: .singleton
        ).link(ToastService.self)
        registerFactory(
            ToastView.self,
            resolver: { payload in
                
                return ToastView(payload: payload as! ToastPayload)
            },
            qualifier: ""
        ).link(ToastView.self)
        register(
            ToastViewController.self,
            resolver: {
                let _0 = context.get(ToastViewReactor.self, qualifier: "")!
                return ToastViewController(_0)
            },
            qualifier: "",
            scope: .weak
        )
        register(
            ToastViewReactor.self,
            resolver: {
                let _0 = context.get(ToastService.self, qualifier: "")!
                return ToastViewReactor(_0)
            },
            qualifier: "",
            scope: .prototype
        )
        registerFactory(
            TodoCellReactor.self,
            resolver: { payload in
                let _0 = context.get(TodoService.self, qualifier: "")!
                return TodoCellReactor(_0, payload: payload as! TodoCellPayload)
            },
            qualifier: ""
        ).link(TodoCellReactor.self)
        register(
            TodoServiceImpl.self,
            resolver: {
                let _0 = context.get(TodoRepository.self, qualifier: "local")!
                let _1 = context.get(AuthService.self, qualifier: "")!
                return TodoServiceImpl(local: _0, _1)
            },
            qualifier: "",
            scope: .singleton
        ).link(TodoService.self)
        register(
            TodoSyncServiceImpl.self,
            resolver: {
                let _0 = context.get(TodoRepository.self, qualifier: "local")!
                let _1 = context.get(TodoRepository.self, qualifier: "remote")!
                let _2 = context.get(AuthService.self, qualifier: "")!
                let _3 = context.get(SchedulerType.self, qualifier: "sync")!
                return TodoSyncServiceImpl(local: _0, remote: _1, _2, sync: _3)
            },
            qualifier: "todo",
            scope: .always
        )
        register(
            TodoViewController.self,
            resolver: {
                let _0 = context.get(TodoViewReactor.self, qualifier: "")!
                let _1 = context.get(AppAnalytics.self, qualifier: "")!
                return TodoViewController(_0, _1)
            },
            qualifier: "",
            scope: .weak
        )
        register(
            TodoViewReactor.self,
            resolver: {
                let _0 = context.get(TodoService.self, qualifier: "")!
                return TodoViewReactor(_0)
            },
            qualifier: "",
            scope: .prototype
        )
        register(
            UIWindow.self,
            resolver: {
                let parent = context.get(WindowConfiguration.self, qualifier: "")!
                return parent.mainWindow() as AnyObject
            },
            qualifier: "",
            scope: .singleton
        )
        register(
            UIWindow.self,
            resolver: {
                let parent = context.get(WindowConfiguration.self, qualifier: "")!
                return parent.toastWindow() as AnyObject
            },
            qualifier: "toast",
            scope: .always
        )
        register(
            WindowConfiguration.self,
            resolver: {
                return WindowConfiguration()
            },
            qualifier: "",
            scope: .singleton
        )
    }
}