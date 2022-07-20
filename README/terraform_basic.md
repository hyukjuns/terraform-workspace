# Basics
### 변수 우선 순위
1. Environment variables
2. The terraform.tfvars file, if present.
3. The terraform.tfvars.json file, if present.
4. Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical order of their filenames.
5. Any -var and -var-file options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)

### 버전 지시자 '~>'
가장 오른쪽 버전 구성 요소만 증가 예를들어, ~> 1.0.4는 1.0.5 및 1.0.10 설치를 허용하지만 1.1.0은 허용하지 않습니다.

### Provider
#### terraform block
테라폼과 프로바이더의 버전을 따로 관리할 수 있음
- required_version: 특정 테라폼 버전 고정
- required_providers: 특정 프로바이더의 버전 고정

#### data block
provider의 리소스 상태를 불러오기 위한 블럭

# Commands
### Refresh
refresh는 configuration file에 의해 생성된 실제 리소스의 변경사항을 state file에 업데이트 합니다.
### import
import는 테라폼의 관리대상이 아닌 리소스를 state file로 불러옴, 사전에 configuration에 해당 리소스를 정의 해줘야 합니다.
```
terraform import <ADDR> <ID>
```

# Modules
### Module
재사용성을 높이기 위해 module을 사용한다. dev,stage,production 환경을 나눌 경우 각 환경에서 리소스를 만들기위해 코드를 복붙할 필요 없이 모듈을 사용해 재사용성을 높일 수 있다.
### Directory 구조
```
module
 ├── main.tf
 ├── outputs.tf
 └── variables.tf
main.tf -> main.tf에서 module을 사용해서 넣은 값 들은 모듈 디렉토리 밑에 variables.tf로 들어가서 모듈 밑의 main.tf로 맵핑됨, 혹은 module 밑에 variables.tf에 값을 넣고 외부 main.tf에서 필요한 값만 바꿔서 모듈을 재사용할 수 있다.
```
### modules.json
모듈 설정 확인 가능
