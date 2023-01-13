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
    mapping(string => DeathCertificate) deathCertificate;

    function applyDeathCert(string memory _decAID, string memory _appAID, bool _naturalDeath, string memory _firID, string memory _stationID) public {
        
        // verify if person already has deathCertificate
        require(bytes(deathCertificate[_decAID].deceasedAID).length == 0, "death certificate already exists");

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
        deathCertificate[_decAID] = certificates[certificates.length-1];
    }

    // helper for STEP 1
    function viewCert(string memory _decAID) public view returns (string memory applicantAID, bool isNaturalDeath, string memory firID) {
        return(deathCertificate[_decAID].applicantAID,deathCertificate[_decAID].isNaturalDeath,deathCertificate[_decAID].firID);
    }

    // STEP 2 : LIST OF ELIGIBLE PEOPLE
    address officerAddress = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    function addHeirList(string memory _decAID, string[] memory _listHeirAID) public {
        
        // check for authorized officer
        require(msg.sender == officerAddress, "unauthorized function call");

        // officer should be able to add to list till legal heir not assigned
        // check if legal heir assigned already
        require(deathCertificate[_decAID].hasLegalHeir != true, "legal heir assigned already");

        for (uint i = 0; i < _listHeirAID.length; i++) {
            deathCertificate[_decAID].elibigleHeirs.push(_listHeirAID[i]);
        }
        // !! capture relation along with aadharID
    }

    // helper for STEP 2
    function viewEligibleList(string memory _decAID) public view returns(string[] memory listHeirAID){
        return(deathCertificate[_decAID].elibigleHeirs);
    }

    // STEP 3 : APPLY LEGAL HEIR
    function applyHeir(string memory _decAID, string memory _heirAID) public {
        
        // check if death certificate exists
        require(bytes(deathCertificate[_decAID].deceasedAID).length != 0, "no death certificate");

        // check if no one has applied before
        require(deathCertificate[_decAID].hasLegalHeir != true, "legal heir already assigned");

        // check if applying person is in the list
        bool isValidHeir = false;
        for (uint i=0; i < deathCertificate[_decAID].elibigleHeirs.length; i++) {
            if (keccak256(abi.encodePacked(deathCertificate[_decAID].elibigleHeirs[i])) == keccak256(abi.encodePacked(_heirAID))) {
                isValidHeir = true;
            }
        }
        require(isValidHeir == true, "applicant is not eligible for legal heir");

        // update legalHeir in deathCertificate
        deathCertificate[_decAID].hasLegalHeir = true;
        deathCertificate[_decAID].heirAID = _heirAID;
    }

    // helper for STEP 3
    function viewHeir(string memory _decAID) public view returns (bool hasHeir, string memory heirAID){
        return(deathCertificate[_decAID].hasLegalHeir, deathCertificate[_decAID].heirAID);
    }
}