# Jmeter
`https://jmeter-plugins.org/install/Install/` 에서
[plugins-manager.jar](https://jmeter-plugins.org/get) 을 다운로드 받아 lib/ext 폴더에 넣는다.<br>
option->plugin manager 에서
Custom Thread Groups , Basic Graphs 을 추가

##  jp@gc – Stepping Thread Group (deprecated) 생성
Max 200 Thread 생성  30초후에 10개씩 Thread 생성 최대 Thread로 600초간 유지이후에 1초 간격으로 5개씩 Thread Stop<br>
This group will start 는 총 몇개의 Thread를 발생할것인가.<br>
Next, add는 몇개씩 더해질것인가<br>
threads every 몇초후에 더해질것인가<br>
using ramp-up는 Next add되는 데 걸리는 시간<br>
Then hold load for는 몇초동안 최대 Thread를 유지할것인가<br>
Final stop 몇개씩 Thread를 줄일것인가<br>
threads every 는 몇초간격으로 줄일것인가.<br>
## 결과보기
jp@gc – Response Times Over Time 생성 : 테스트 시간에 따른 응답 시간<br>
 jp@gc – Transactions per Second 생성 : 초당 처리량 확인<br>
jp@gc – Response Times vs Threads : Thread 변화에 따른 응답 속도<br>
jp@gc – Composite Graph : 종합 적인 그래프를 함께 보여준다.<br>
