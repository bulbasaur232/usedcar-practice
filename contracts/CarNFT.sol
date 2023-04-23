// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CarNFT is ERC721URIStorage, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    
    /*
    struct Accident {
        uint timestamp; // 사고 발생 일시
        string location; // 사고 발생 위치
        string description; // 사고 설명
    }

    struct Maintenance {
        uint timestamp; // 정비 일시
        string location; // 정비 위치 
        string description; // 정비 설명
    }

    struct Trade {
        string from; // 판매자
        string to; // 구매자
        uint timestamp; // 판매일자
        uint price; // 가격
        string description; // 설명
    }
    */
    
    struct Car {
        string carName;                // 차 이름
        string ownerName;              // 현재 소유자  
        string[] ownerHistory;         // 명의이전내역
        string[] accidentHistory;      // 사고이력
        string[] maintenanceHistory;   // 정비이력
        string[] tradeHistory;         // 거래이력
    }
    
    constructor() ERC721("CarNFT", "CAR") {}

    // 차량id - 차량정보 매핑
    mapping(uint256 => Car) private _carInfo;

    // 주소 - 차량id목록 매핑
    mapping(address => uint256[]) private _carsOfOwner;

    // 차량 등록 이벤트
    event CarNFTMinted(
        uint256 tokenId,
        string carName,
        string ownerName
    );

    // carNFT 발행 함수
    function mintCarNFT(
        address _ownerAddress,
        string memory _carImageURI,
        string memory _carName,
        string memory _ownerName
    ) public onlyOwner {

        uint tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(_ownerAddress, tokenId);
        _setTokenURI(tokenId, _carImageURI); // 해당 차량의 사진URI 등록

        _carInfo[tokenId].carName = _carName;
        _carInfo[tokenId].ownerName = _ownerName;
        _carsOfOwner[_ownerAddress].push(tokenId);

        emit CarNFTMinted(tokenId, _carName, _ownerName);
    }

    // tokenId에 해당하는 차량 정보 조회 함수
    function getCarInfo(uint256 _tokenId)
        public view returns (
            string memory carName,                // 차 이름
            string memory ownerName,              // 현재 소유자  
            string[] memory ownerHistory,         // 명의이전내역
            string[] memory accidentHistory,      // 사고이력
            string[] memory maintenanceHistory,   // 정비이력
            string[] memory tradeHistory,         // 거래이력
            string memory carImageURI             // 차량 이미지 URI
        )
    {
        require(_exists(_tokenId), "CarNFT: Token ID does not exist");

        Car memory car = _carInfo[_tokenId];
        return (
            car.carName,
            car.ownerName,
            car.ownerHistory,
            car.accidentHistory,
            car.maintenanceHistory,
            car.tradeHistory,
            _showImage(_tokenId)
        );
    }

    // 차량이미지 URI 반환 
    function _showImage(uint _tokenId) private view returns (string memory) {
        require(_exists(_tokenId), "CarNFT: Token ID does not exist");
        return tokenURI(_tokenId);
    }

    // 명의이전내역 추가
    function setOwnerHistory(uint _tokenId, string[] memory _previousOwners) public onlyOwner {
        require(_exists(_tokenId), "CarNFT: Token ID does not exist");

        for(uint i = 0; i < _previousOwners.length; i++){
             _carInfo[_tokenId].ownerHistory.push(_previousOwners[i]);
        }
    }

    // 사고이력 추가
    function setAccidentHistory(uint _tokenId, string[] memory _accidents) public onlyOwner {
        require(_exists(_tokenId), "CarNFT: Token ID does not exist");

        for(uint i = 0; i < _accidents.length; i++){
             _carInfo[_tokenId].accidentHistory.push(_accidents[i]);
        }
    }

    // 정비이력 추가
    function setMaintenanceHistory(uint _tokenId, string[] memory _maintenances) public onlyOwner {
        require(_exists(_tokenId), "CarNFT: Token ID does not exist");

        for(uint i = 0; i < _maintenances.length; i++){
             _carInfo[_tokenId].maintenanceHistory.push(_maintenances[i]);
        }
    }

    // 거래이력 추가
    function setTradeHistory(uint _tokenId, string[] memory _trades) public onlyOwner {
        require(_exists(_tokenId), "CarNFT: Token ID does not exist");

        for(uint i = 0; i < _trades.length; i++){
             _carInfo[_tokenId].tradeHistory.push(_trades[i]);
        }
    }

    function carsByOwner(address _ownerAddress) public view returns (uint256[] memory){
        return _carsOfOwner[_ownerAddress];
    }

}