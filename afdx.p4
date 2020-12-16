header_type afdx_frame_t {
  // à compléter
  fields {
    cst_field : 32;
    VL_id : 16;
    srcAddr : 48;
    typeFrame : 16;
  }
}

header afdx_frame_t afdx_frame;

header_type intrinsic_metadata_t {
  fields {
    ingress_global_timestamp: 48;
    egress_global_timestamp: 48;
    lf_field_list: 8;
    mcast_grp: 16;
    egress_rid: 16;
    resubmit_flag: 8;
    recirculate_flag: 8;
  }
}

metadata intrinsic_metadata_t intrinsic_metadata;

parser start {
       return parse_afdx_frame;
}



// à compléter pour gérer l'AFDX
#define AFDX_VL 0x03000000
parser parse_afdx_frame {
  extract (afdx_frame);
  return select(latest.cst_field){
    AFDX_VL : ingress;
    // default : reject;
  }
}

// parser parse_intrinsic_metadata {
//   extract (intrinsic_metadata);
//   return select(latest.mcast_grp){
//     AFDX_VL : ingress;
//     // default : reject;
//   }
// }

action commut_afdx(port){
  modify_field(standard_metadata.egress_spec, port);
}

action set_multicast()

action _drop(){
  drop();
}

table commut_table {
  reads {
    afdx_frame.VL_id : exact;
    intrinsic_metadata.mcast_grp : exact;
  }
  actions {
    commut_afdx;
    _drop;
  }
}

control ingress {
	// à compléter
  apply(commut_table);
}

control egress {
	// ne pas modifier
}

       
