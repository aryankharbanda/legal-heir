// SPDX-License-Identifier: MI
pragma solidity ^0.8.1;

// officer
// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

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

        bool hasHeirApplication; // default: false
        string[] heirAIDs;
        
        bool hasLegalHeir;
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
    address[] officerAddresses = [0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db];
    function isOfficer(address address1) private view returns(bool officer){
        for(uint i = 0; i < officerAddresses.length; ++i){
            if(officerAddresses[i] == address1){
                return true;
            }
        }
        return false;
    }

    string[] validRelations = ["mother", "father", "brother", "sister", "son", "daughter", "grandchild"];
    function addHeirList(string memory _decAID, string[] memory _listHeirAID, string[] memory _listHeirRelation) public {
        
        // check for authorized officer
        require(isOfficer(msg.sender) == true, "address not authorized");

        // officer should be able to add to list till legal heir not assigned
        // check if legal heir assigned already
        require(deathCertificate[_decAID].hasLegalHeir != true, "legal heir assigned already");

        for (uint i = 0; i < _listHeirAID.length; i++) {
            // avoid duplicates in eligibleHeirs
            // iterate array or use mapping
            bool alreadyExists = false;
            for(uint j = 0; j < deathCertificate[_decAID].elibigleHeirs.length; j++){
                if (keccak256(abi.encodePacked(deathCertificate[_decAID].elibigleHeirs[j])) == keccak256(abi.encodePacked(_listHeirAID[i]))) {
                    alreadyExists = true;
                }
            }
            if(alreadyExists == false){
                // check for valid relation
                bool isValidRelation = false;
                for(uint j=0; j<validRelations.length; j++){
                    if(keccak256(abi.encodePacked(_listHeirRelation[i])) == keccak256(abi.encodePacked(validRelations[j]))){
                        isValidRelation = true;
                    }
                }
                require(isValidRelation == true, "one or more legal heir do not have valid relation");
                
                // check if legal heir not already deceased
                require(bytes(deathCertificate[_listHeirAID[i]].deceasedAID).length == 0, "one or more legal heir already deceased");
                
                deathCertificate[_decAID].elibigleHeirs.push(_listHeirAID[i]);    
            }
        }
    }

    // helper for STEP 2
    function viewEligibleList(string memory _decAID) public view returns(string[] memory listHeirAID){
        return(deathCertificate[_decAID].elibigleHeirs);
    }

    // STEP 3 : APPLY LEGAL HEIR
    function applyHeirApplication(string memory _decAID, string[] memory _heirAIDs) public {
        
        // check if death certificate exists
        require(bytes(deathCertificate[_decAID].deceasedAID).length != 0, "no death certificate");

        // check if legal heir already assigned
        require(deathCertificate[_decAID].hasLegalHeir != true, "legal heir already assigned");

        // check if no one has applied before
        require(deathCertificate[_decAID].hasHeirApplication != true, "legal heir application already under review");

        // check if array not empty
        require(bytes(_heirAIDs[0]).length != 0, "provide atleast one heir");

        // check if all applying heirs are in the list
        bool isValidApplication = true;
        for(uint j = 0; j < _heirAIDs.length; j++){
            bool isValidHeir = false;
            for (uint i = 0; i < deathCertificate[_decAID].elibigleHeirs.length; i++) {
                if (keccak256(abi.encodePacked(deathCertificate[_decAID].elibigleHeirs[i])) == keccak256(abi.encodePacked(_heirAIDs[j]))) {
                    isValidHeir = true;
                }
            }
            if(isValidHeir == false){
                isValidApplication = false;
            }
        }
        require(isValidApplication == true, "one or more applicant(s) is not eligible for legal heir");

        deathCertificate[_decAID].hasHeirApplication = true;
        for(uint i = 0; i < _heirAIDs.length; i++){
            deathCertificate[_decAID].heirAIDs.push(_heirAIDs[i]);
        }

        // is done in step4
        // // update legalHeir in deathCertificate
        // deathCertificate[_decAID].hasLegalHeir = true;
        // deathCertificate[_decAID].heirAID = _heirAID;
    }

    // helper for STEP 3
    function viewHeirApplication(string memory _decAID) public view returns (bool hasHeirApplication, bool hasLegalHeir, string[] memory heirAIDs){
        return(deathCertificate[_decAID].hasHeirApplication, deathCertificate[_decAID].hasLegalHeir, deathCertificate[_decAID].heirAIDs);
    }

    // alloted heirAIDs
    function viewHeirList(string memory _decAID) public view returns(string[] memory listHeirAID){
        return(deathCertificate[_decAID].heirAIDs);
    }

    // STEP 4
    function approveApplication(string memory _decAID) public {
        // check for authorized officer
        require(isOfficer(msg.sender) == true, "address not authorized");
        
        deathCertificate[_decAID].hasLegalHeir = true;
    }
    
    function declineApplication(string memory _decAID) public {
        // check for authorized officer
        require(isOfficer(msg.sender) == true, "address not authorized");
        
        deathCertificate[_decAID].hasHeirApplication = false;
        for(uint i = 0; i < deathCertificate[_decAID].heirAIDs.length; i++){
            deathCertificate[_decAID].heirAIDs.pop();
        }
    }

}