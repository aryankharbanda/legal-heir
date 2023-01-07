// SPDX-License-Identifier: MI
pragma solidity ^0.8.1;

contract LegalHeir{
    
    // STEP 1 : DEATH CERTIFICATE
    struct DeathCertificate { 
        // AID = Aadhar ID
        string deceased_AID;
        string applicant_AID;
        bool FIR;
    }

    DeathCertificate[] certificates;
    mapping(string => uint) certificateID;

    function applyDeathCert(string memory _decAID, string memory _appAID, bool _fir) public {
        
        certificates.push(DeathCertificate(_decAID, _appAID, _fir));
        
        // minimum ID value is 1
        certificateID[_decAID] = certificates.length;
    }

    function verifyCert() public view returns (string memory lastAID) {
        return certificates[certificates.length-1].deceased_AID;
    }

    // STEP 2 : LIST OF ELIGIBLE PEOPLE


    // STEP 3 : APPLY LEGAL HEIR
    struct Heir { 
        string deceased_AID;
        string heir_AID;
        address heir_add;
    }
    Heir[] heirApplications;
    mapping(string => uint) heirID;

    function applyHeir(string memory _decAID, string memory _heirAID) public {
        
        // check if death certificate exists
        require(certificateID[_decAID] != 0);

        // check if no one has applied before
        require(heirID[_decAID] == 0);

        heirApplications.push(Heir(_decAID, _heirAID, msg.sender));
        heirID[_decAID] = heirApplications.length; 
    }

}