// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.5.16;
//import "https://github.com/pubkey/eth-crypto.git";

contract Access_Control_Contract
{
   
    struct Nes {
        //next entry structure
        
        bytes32 filename;
        uint encr_smk;
        uint id;
        bool read_permit;
        bool write_permit;
        address _address;
        
    }
    
    mapping(address => Nes) public patients;
    mapping(address => Nes) public providers;
    
    enum status { requested_new_level, request_invalid, waiting_approval, approved, not_approved, inactive}
    status pat_status;
    status constant default_patstat = status.inactive;
    status prov_status;
    
    enum ownership { owner, read, blind_read, undefined, access_other}
    ownership pat_own;
    ownership constant default_patown = ownership.read;
    ownership prov_own;
    ownership constant default_provown = ownership.owner;
   
    
    address private _owner; //prc
    Nes  nes;
    bool read_permit = false;
    bool write_permit = false;
    uint last_update;
    
    constructor() public {
    _owner = msg.sender;
    
    }
    
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
      }
    
    function assignPermission(bytes32 _filename , uint  id) public payable returns(ownership){
        if (_filename == nes.filename )
            if (id == nes.id){
                pat_status = status.inactive;
                pat_own = ownership.read;
                nes.read_permit = true;
            }
             if (id == nes.id){
                pat_status = status.inactive;
                pat_own = ownership.owner;
                nes.read_permit = true;
                nes.write_permit = true;
            }
             if (id != nes.id && id != nes.id){
                pat_status = status.inactive;
                pat_own = ownership.blind_read;
            }
        else
        { return ownership.undefined; }
    }
    
    function assignPermission(bytes32 _filename , address _addr) public payable returns(ownership){
        if (_filename == nes.filename )
            if (_addr == nes._address){
                pat_status = status.inactive;
                pat_own = ownership.read;
                nes.read_permit = true;
            }
             if (_addr == nes._address){
                pat_status = status.inactive;
                pat_own = ownership.owner;
                nes.read_permit = true;
                nes.write_permit = true;
            }
             if (_addr != nes._address && _addr != nes._address){
                pat_status = status.inactive;
                pat_own = ownership.blind_read;
            }
        else
        { return ownership.undefined; }
    }
    
    function isReadQualified(address _addr) public payable returns(bool){
        bool allow = false;
        if(_addr == nes._address && pat_own != ownership.undefined && pat_status == status.approved){
            allow = true;
        }
        return allow;
    }
    
    function isOwnQualified(address _addr) public payable returns(bool){
        bool allow = false;
        if(_addr == nes._address && prov_own == ownership.owner && pat_status == status.approved){
            allow = true;
        }
        return allow;
    }
    
    function isExtraQualified(address _addr) public payable returns(bool){
        bool allow = false;
        if(_addr == nes._address && prov_own == ownership.access_other && pat_status == status.approved){
            allow = true;
        }
        return allow;
    }
    
    function isBlReadQualified(address _addr) public payable returns(bool){
        bool allow = false;
        if(_addr == nes._address && prov_own == ownership.blind_read && pat_status == status.approved){
            allow = true;
        }
        return allow;
    }
    
    function requestFromPRC(bytes32 _filename , uint id)internal {
        ownership cur_own;
        cur_own = assignPermission(_filename,id);
        sendEncSMKtoPRC();
        last_update = block.timestamp;
    }
    
    function requestFromPRC(bytes32 _filename , address _addrd)internal {
        ownership cur_own;
        cur_own = assignPermission(_filename,_addrd);
        sendEncSMKtoPRC();
        last_update = block.timestamp;
    }
    
    function sendEncSMKtoPRC() internal view onlyOwner returns(uint _key){
       if( pat_own != ownership.undefined && prov_own != ownership.undefined){
            return _key = nes.encr_smk;
       }
    }
    
    function sendAddrsstoPRC() internal view returns(address _cont){
        return address(this);
    }
    
    function newAccessLevel (address _pradd, ownership prown) public payable onlyOwner returns(status prot,bool _given){
        bool confirm = true;
        
        if(_pradd == nes._address){
            
            if(prown != prov_own){
                
                prov_status =status.requested_new_level;
                last_update = block.timestamp;
                //bool confirm = askPatient();
                prov_status = status.waiting_approval;
                
                if (confirm == true){   
                    prov_own = prown;
                    prov_status = status.approved;
                    return (prov_status,true);
                    }
                else
                    prov_status= status.not_approved;
                    return (prov_status,false);
            }
            
        }
        last_update = block.timestamp;
    }
    
    function readfromAnother(address _pradA, address _pradB) public payable onlyOwner returns(status _prot, uint _key){
        bool bool0;
        bool bool01;
        require(_pradA != _pradB);
        bool01 = isExtraQualified(_pradA);
        if (bool01 == true)
            (_prot,bool0) = newAccessLevel(_pradB, ownership.access_other);
        return (_prot,nes.encr_smk);
    }
    
}