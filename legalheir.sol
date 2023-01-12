// SPDX-License-Identifier: MI
pragma solidity ^0.8.1;

// officer
// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

contract LegalHeir{
    
    // STEP 1 : DEATH CERTIFICATE
    struct DeathCertificate { 
        // AID = Aadhar ID
        string deceasedAID;
        string applicantAID;
 
        bool isNaturalDeath;
        string firID;        
        string stationID;

        string[] elibigleHeirs;

        bool hasLegalHeir;
        string heirAID;
    }

    DeathCertificate[] certificates;

    // !! mapping from struct to int ID
    mapping(string => uint) certificateID;

    function applyDeathCert(string memory _decAID, string memory _appAID, bool _naturalDeath, string memory _firID, string memory _stationID) public {
        
        // verify if person already has deathCertificate
        require(certificateID[_decAID] == 0, "death certificate already exists");

        DeathCertificate memory cert;
        cert.deceasedAID = _decAID;
        cert.applicantAID = _appAID;
        cert.isNaturalDeath = _naturalDeath;
        if(_naturalDeath == false){
            require(bytes(_firID).length != 0, "provide firID for unnatural death");
            require(bytes(_stationID).length != 0, "provide stationID for unnatural death");
            cert.firID = _firID;
            cert.stationID = _stationID;
        }

        certificates.push(cert);
        // certificates.push(DeathCertificate(_decAID, _appAID, _fir, []));
        
        // minimum ID value is 1
        certificateID[_decAID] = certificates.length;
    }

    // STEP 2 : LIST OF ELIGIBLE PEOPLE
    address officerAddress = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    function addHeirList (string[] memory _listHeirAID, string memory _decAID) public {
        
        // check for authorized officer
        require(msg.sender == officerAddress, "unauthorized function call");

        // officer should be able to add to list till legal heir not assigned
        // check if legal heir assigned already
        require(certificates[certificateID[_decAID]-1].hasLegalHeir != true, "legal heir assigned already");

        for (uint i = 0; i < _listHeirAID.length; i++) {
            certificates[certificateID[_decAID]-1].elibigleHeirs.push(_listHeirAID[i]);
        }
        // !! capture relation along with aadharID
    }

    // STEP 3 : APPLY LEGAL HEIR
    function applyHeir(string memory _decAID, string memory _heirAID) public {
        
        // check if death certificate exists
        require(certificateID[_decAID] != 0, "no death certificate");

        // check if no one has applied before
        require(certificates[certificateID[_decAID]-1].hasLegalHeir != true, "legal heir already assigned");

        // check if applying person is in the list
        bool isValidHeir = false;
        for (uint i=0; i < certificates[certificateID[_decAID]-1].elibigleHeirs.length; i++) {
            if (keccak256(abi.encodePacked(certificates[certificateID[_decAID]-1].elibigleHeirs[i])) == keccak256(abi.encodePacked(_heirAID))) {
                isValidHeir = true;
            }
        }
        require(isValidHeir == true, "applicant is not eligible for legal heir");

        // update legalHeir in deathCertificate
        certificates[certificateID[_decAID]-1].hasLegalHeir = true;
        certificates[certificateID[_decAID]-1].heirAID = _heirAID;
    }

    // helper functions for demo purposes

    // STEP1
    function viewCert(string memory _decAID) public view returns (string memory applicantAID, bool isNaturalDeath, string memory firID) {
        return(certificates[certificateID[_decAID]-1].applicantAID, certificates[certificateID[_decAID]-1].isNaturalDeath, certificates[certificateID[_decAID]-1].firID);
    }

    // STEP2
    function viewEligibleList(string memory _decAID) public view returns(string[] memory listHeirAID){
        return(certificates[certificateID[_decAID]-1].elibigleHeirs);
    }

    // STEP3
    function viewHeir(string memory _decAID) public view returns (bool hasHeir, string memory heirAID){
        return(certificates[certificateID[_decAID]-1].hasLegalHeir, certificates[certificateID[_decAID]-1].heirAID);
    }

}