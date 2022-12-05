# Blink

## 연구 배경

- 최근 수십년간 디스플레이를 바라보며 업무를 수행하고, 오락, 여가를 즐기는 시간이 비약적으로 증가하였다.
- 디스플레이에 집중하다 보니 눈을 깜빡이는 횟수가 줄었고, 이로 인해 안구건조증을 겪는 환자가 점점 증가하는 추세이다. 실제로 건강심사평가원이 밝힌 스마트폰 관련 6대 질환의 진료비 중 1위 질환이 안구 건조증이다.
- 안구건조증을 예방하는 가장 쉬운 방법은 전자 기기 사용 시 눈을 자주 깜빡이는 것이지만, 이를 의식적으로 행하기는 매우 어려워 본 앱을 제안한다.

## 관련 연구 
- 얼굴 인식 라이브러리
    - OpenPose
- 얼굴 인식 프레임워크
    - ARKit
    - MediaPipe

## 시스템 설명

- 로그인 화면
    - 사용자의 데이터를 개인화하여 관리하기 위해 애플의 Authentication Services 프레임워크를 이용한 Apple로 로그인 기능을 제공
    - 애플로 로그인이 성공할 경우, 애플로부터 사용자 식별에 이용되는 User Identifier를 넘겨받게 되며, 이를 애플 고유의 암호화된 데이터베이스인 Keychain에 저장하여 안전하게 관리

![image](https://user-images.githubusercontent.com/29617557/205551159-400aaa9e-5358-4265-becb-94caf593c59d.jpeg)

- 눈 깜빡임 탐지 관련 화면 구성
    - 아이폰의 전면  TrueDepth Camera를 이용하여 사용자의 얼굴을 지속적으로 관찰하고 ARKit 프레임워크의 ARSession을 이용하여 눈을 분석
![image](https://user-images.githubusercontent.com/29617557/205551249-b8025ae6-e7e4-4120-a9ab-bd7583d6aa7b.png)

- 경고 화면
    - 사용자가 눈을 12회 미만으로 깜빡일 때는 조심하라는 메시지가 담긴 Notification을 소리, 진동과 함께 전송

![image](https://user-images.githubusercontent.com/29617557/205551290-980c53d2-e26d-4a90-88e7-71abc4ed0cd6.png)

- 암전 

![image](https://user-images.githubusercontent.com/29617557/205551344-2da370ad-d0ef-41dd-a1de-10dc621c4f3c.png)

- 차트
    - Firebase Realtime Database를 이용하여 데이터베이스를 구성하여 분 당 눈 깜빡임 횟수를 실시간으로 저장하고, 차트 버튼을 누르면 이 데이터를 불러와 차트를 구성
    
![image](https://user-images.githubusercontent.com/29617557/205551370-6634f6dc-1563-4728-980a-b6be812c9284.png)