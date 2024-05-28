import { LightningElement,track } from 'lwc';
import FetchUsers from '@salesforce/apex/CloneUserPermissionandGroups.FetchUsers';
import Clone from '@salesforce/apex/CloneUserPermissionandGroups.Clone';
	
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CloneUserPermissionGroups extends LightningElement {
    isShowModal = false;
    @track users = [];
    btn;
    spin = false;
    handleModel(){
        this.isShowModal = !this.isShowModal;
    }

    handleButton(event){
        this.btn = event.target.dataset.btn;
        this.handleModel();
    }

    Toast(title,msg,varient){
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: varient,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    async GetUsers(){
        this.spin = true;
        const value = this.template.querySelector(".search").value;
        await FetchUsers({KeyWord:value})
        .then(result => {
            this.users = result;
            console.log(result);
        })
        .catch(error =>{
            console.log(error);
        })
        this.spin=false;
    }

    InsertInp(event){
        if(this.btn === 'userid'){
            this.template.querySelector(".userid").value = event.target.dataset.name + '#' + event.target.dataset.id;
        }
        else if(this.btn === 'cloneid'){
            this.template.querySelector(".cloneid").value = event.target.dataset.name + '#' + event.target.dataset.id;
        }
        this.handleModel();
    }

    async CloneUser(){
        this.spin=true;
        const IsPS = this.template.querySelector('.ps').checked;
        const IsPGQ = this.template.querySelector('.pgq').checked;
        const IsPSA = this.template.querySelector('.psa').checked;
        const cloneid =this.template.querySelector('.cloneid').value.split("#")[1];
        const userid =this.template.querySelector('.userid').value.split("#")[1];
        console.log(IsPS,IsPGQ,IsPSA,cloneid,userid);
        if(cloneid && userid && (IsPS || IsPGQ || IsPSA)){
            await Clone({IsPS:IsPS,IsPGQ:IsPGQ,IsPSA:IsPSA,UserId:userid,CloneId:cloneid})
            .then(result => {
                console.log("Done",result);
                this.Toast('Success','Cloned successfully','success');
            })
            .catch(error =>{
                console.log(error);
                this.Toast('Error',error.body.message,'error');
            });
        }
        else{
            this.Toast('Error','Please provide UserId & Clone Id and select atleast one component to clone.','warning');
        }
        this.spin=false;
    }
}