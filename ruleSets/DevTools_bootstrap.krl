//for flushing: http://cs.kobj.net/ruleset/flush/b506607x15.prod;b506607x15.dev
ruleset DevTools_bootstrap {
    meta {
        name "DevTools Bootstrap"
        description <<
            Bootstrap ruleset for DevTools
        >>

        use module a169x625 alias CloudOS
        logging on

        provides testingReturns
        sharing on
    }

    global {

        rulesets = {
            "core": [
                   "a169x625.prod",  // CloudOS Service
                   "a169x676.prod",  // PDS
                   "a16x129.dev",    // SendGrid module
                   "b506607x14.prod", //DevTools
                   "b16x29.prod"     // logging
            ],
	    "unwanted": []
        };

        testingReturns = function(){
          rulesets = CloudOS:rulesetList(meta:eci()).defaultsTo({}, ">> list of installed rulesets undefined >>");
          rulesets;
        };
    }

    rule bootstrap_guard {
      select when devtools bootstrap
      pre {
        installed_rids = CloudOS:rulesetList(meta:eci()).defaultsTo({}, ">> list of installed rulesets undefined >>");
	      rids = rulesets{"rids"};
        bootstrapped = installed_rids.filter(function(k,v){v eq "b506607x14.prod"}).length();// check if installed_rids includes b506607x14.prod --- use a filter and check if length is > 0.
      
      }
      if (bootstrapped > 0 ) then
      {
        send_directive("found_b506607x14.prod_for_developer") 
	         with eci = eci;
      }
      fired {
	      log ">>>> pico already bootstraped, saw : " + installed_rids;
      } else {
        log ">>>> pico needs a bootstrap >>>> ";
        log ">>>> pico installed_rids, saw : " + rids.encode();
        log ">>>> pico installed_rids.filter(function(k,v){v eq b506607x14.prod}), saw : " + installed_rids.filter(function(k,v){v eq "b506607x14.prod"}).encode();
        log ">>>> pico installed_rids.filter(function(k,v){v eq b506607x14.prod}).length();, saw : " + installed_rids.filter(function(k,v){v eq "b506607x14.prod"}).length();
        raise explicit event bootstrap_needed;
        
      }
    }

    rule devtools_bootstrap {
        select when explicit bootstrap_needed
        pre {
          installed = CloudOS:rulesetAddChild(rulesets{"core"}, meta:eci());
        }
        if (installed) then {
            send_directive("New DevTools user bootstrapped") //with
        }
        fired {
            log "DevTools user bootstrap succeeded";

        } else {
            log "DevTools user bootstrap failed";
        }
    }

}