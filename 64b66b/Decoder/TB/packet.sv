class packet;
    rand bit [65:0] tdata;

    constraint constr_sync {
        tdata[65:64] inside {2'b01, 2'b10};
    }

endclass
