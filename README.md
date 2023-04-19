# Cценарий по настройке NATa для доступа к Yandex Cloud S3

Этот Terraform плейбук позволяет создать стенд для осуществления ната в эндпойнты сервисов Яндекс Облака, необходимые для работы инстансов Yandex Data Proc, на основе внутреннего балансера и виртуальных машин c IPtables правилами.
Для корректной работы плейбука потребуется флаг MDB_DATAPROC_DISABLE_NETWORK_CHECK - обратитесь в техническую поддержку для его установки.

## Установка YC-CLI

Для устанвки YC CLI можно использовать следующий гайд [YC CLI](https://cloud.yandex.ru/docs/cli/quickstart)

## Авторизация терраформ-провайдера через YC

```bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

<br/>

## Развертывание плейбука

Для запуска создайте файл `terraform.tfvars` с переменными:

```hcl
# количество вм с натом, обычно для отказоустойчивости нужно 3 по одной в зоне доступности
node_count = 3
# преффикс к имени создаваемых ресурсов
name_preffix = "someprefix"
# SSH ключ для виртуальных машин
ssh_public_key = "ssh-rsa <ключ>"

# ID сети в которой будут создаваться подсети (если их ID не указаны в следующей переменной).
# Если переменная не указана, то будет создана новая сеть
network_id = "somenetworkid"
# Список ID подсетей, в которых будут создаваться виртуальные машины (для отказоустойчивости рекомендует 3, под одной в зоне доступности).
# Если не указана переменная, то будут созданы новые подсети.
subnet_ids = [
  "subnet1id",
  "subnet2id",
  "subnet3id"
]
```

#### Вызов терраформа

```bash
terraform init
terraform plan
terraform apply
```

## Удаляем инфраструктуру
## Из-за особенности работы NLB с target VM удаление инфраструктуры необходимо запускать несколько раз, по количеству натируемых эндпойнтов

```bash
terraform destroy
terraform destroy
terraform destroy
terraform destroy
```
