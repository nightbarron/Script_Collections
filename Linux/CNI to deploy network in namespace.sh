#1. Lấy container name
CONTAINER_NAME=demo-container-cni

#2. Chạy container ko có network
docker run -d --network none --name ${CONTAINER_NAME} -t python:3.9.12-alpine3.15 cat - 
docker run --rm -dit --network none ${CONTAINER_NAME} -t python:3.9.12-alpine3.15 cat - 
#3. Download plugin cni theo link
wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-bin-amd64-v1.1.1.tgz
gunzip cni-bin-amd64-v1.1.1.tgz
tar -xf cni-bin-amd64-v1.1.1.tar
mv cni-plugins-linux cni-bin

#4. Lấy container id và container network namespace id càn thực hiện
CONTAINER_ID=$(docker inspect ${CONTAINER_NAME} | jq -r .[].Id)
CONTAINER_Namespace=$(docker inspect ${CONTAINER_NAME} | jq -r .[].NetworkSettings.SandboxKey)

echo ${CONTAINER_ID}
echo ${CONTAINER_Namespace}

#4. Tạo file cấu hình bridge.conf dưới dạng json từ cni

File bridge.conf link: https://www.cni.dev/plugins/current/main/bridge/

Start container mà không có network

Ví dụ
{
    "cniVersion": "1.0.0",
    "name": "devops",
    "type": "bridge",
    "bridge": "devops",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "subnet": "10.20.30.0/24",
        "routes": [
                {"dst": "0.0.0.0/0"}
        ],
        "rangeStart": "10.20.30.100",
        "rangeEnd": "10.20.30.200",
        "gateway": "10.20.30.99"
    },
    "dns": {
        "nameservers": [ "1.1.1.1", "8.8.8.8" ]
    }
}


#5. Thêm card mạng / interface cho container
CONTAINERNamespace=${CONTAINER_Namespace}
CONTAINERID=${CONTAINER_ID} 
echo $CONTAINERNamespace
echo $CONTAINERID

CNI_COMMAND=ADD    CNI_CONTAINERID=${CONTAINER_ID}    CNI_NETNS=${CONTAINER_Namespace}   CNI_IFNAME=eth0   CNI_PATH=${PWD}/cni-bin   cni-bin/bridge   </root/bridge.conf

CNI_COMMAND=ADD   CNI_CONTAINERID=${CONTAINERID}    CNI_NETNS=${CONTAINERNamespace}   CNI_IFNAME=eth0    CNI_PATH=${PWD}/cni-bin  cni-bin/bridge    </root/bridge.conf 


