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
        bool FIR;
        string[] elibigleHeirs;
    }

    DeathCertificate[] certificates;
    mapping(string => uint) certificateID;

    function applyDeathCert(string memory _decAID, string memory _appAID, bool _fir) public {
        
        DeathCertificate memory cert;
        cert.deceasedAID = _decAID;
        cert.applicantAID = _appAID;
        cert.FIR = _fir;

        certificates.push(cert);
        // certificates.push(DeathCertificate(_decAID, _appAID, _fir, []));
        
        // minimum ID value is 1
        certificateID[_decAID] = certificates.length;
    }

    function verifyCert() public view returns (string memory lastAID) {
        return certificates[certificates.length-1].deceasedAID;
    }

    // STEP 2 : LIST OF ELIGIBLE PEOPLE
    address officerAddress = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    function addHeirList(string[] memory _listHeirAID, string memory _deceasedAID) public {
        require(msg.sender == officerAddress);
        
        uint i=0;
        for (i = 0; i < _listHeirAID.length; i++) {
            certificates[certificateID[_deceasedAID]-1].elibigleHeirs.push(_listHeirAID[i]);
        }
    }

    // STEP 3 : APPLY LEGAL HEIR
    struct Heir { 
        string deceasedAID;
        string heirAID;
        address heirAddress;
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