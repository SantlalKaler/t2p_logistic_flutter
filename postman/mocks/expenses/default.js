// Contract: docs/T2P_Expenses_API_Guide.pdf v1.1. Synthetic local test data only.
const http = require('http');
const categories = ['FOOD_PURCHASE','INTERCITY_LOGISTICS','DELIVERY','MISC','PETROL','TRAVEL','CANCELLED_ORDER'];
const labels = ['Food Purchase','Intercity Logistics','Delivery','Miscellaneous','Petrol Filling','Travelling','Cancelled Orders'];
const statuses = ['draft','submitted','approved','rejected','cancelled'];
const money = n => Math.round(Number(n || 0) * 100);
http.createServer(async (req,res) => {
  const send=(code,body)=>{res.writeHead(code,{'content-type':'application/json'});res.end(JSON.stringify(body));};
  const fail=(code,message)=>send(code,{status:'error',message});
  const url=new URL(req.url,'http://localhost'), path=url.pathname, body=req.body||{};
  let s=await pm.state.get('expenses.state')||{records:{},ids:{},balance:500000,entries:[],seq:0};
  const persist=()=>pm.state.set('expenses.state',s);
  const full=e=>({expense:e,category_label:labels[categories.indexOf(e.category)],actions:{
    edit:['draft','rejected'].includes(e.status),upload:['draft','rejected'].includes(e.status),
    submit:e.category!=='CANCELLED_ORDER'&&['draft','rejected'].includes(e.status),recall:e.status==='submitted',
    approve:e.category==='CANCELLED_ORDER'&&e.status==='draft',reject:false,
    cancel:e.category!=='CANCELLED_ORDER'&&['draft','submitted','rejected'].includes(e.status)},history:e.history,
    cash_balance:s.balance,ledger_entries:s.entries.filter(a=>a.expense===e._id)});
  const ledger=(e,reverse=false)=>{if(!e.amount.total)return; s.balance+=e.amount.total*(reverse?1:-1);
    s.entries.unshift({txn_no:`CL-${s.entries.length+1}`,type:reverse?'EXPENSE_REVERSAL':'EXPENSE_DEBIT',type_label:reverse?'Expense Reversal':'Expense',direction:reverse?'credit':'debit',amount:e.amount.total,running_balance:s.balance,business_date:e.business_date,expense:e._id,expense_no:e.expense_no,expense_status:e.status});};
  if(path==='/__reset'&&req.method==='POST'){await pm.state.set('expenses.state',null);return send(200,{status:'success'});}
  if(req.headers.authorization!=='Bearer test-token')return fail(401,'Login required');
  // Local-only fault controls for the real Dio error-path tests.
  if(req.headers['x-expense-test-response']==='429') {
    res.setHeader('Retry-After','2'); return fail(429,'Too many requests');
  }
  if(req.headers['x-expense-test-response']==='500-html') {
    res.writeHead(500,{'content-type':'text/html'}); return res.end('<html>Upstream failed</html>');
  }

  if(path==='/v1/expenses/meta')return send(200,{status:'success',data:{me:{default_city:'city-1',cities:['city-1']},permissions:{expense:{add_edit:true}},categories:categories.map((code,i)=>({code,label:labels[i]})),statuses,travel_modes:[{value:'taxi',label:'Taxi'},{value:'other',label:'Other'}],expense_heads:[{_id:'head-1',name:'Packaging material'}],gst_rate_percent:5,backdate_days:7,upload:{max_files:5,max_mb:10,allowed:'JPG, PNG, WEBP, HEIC or PDF'},ledger_types:{EXPENSE_DEBIT:'Expense',EXPENSE_REVERSAL:'Expense Reversal'}}});
  if(path==='/v1/cash-ledger/me')return send(200,{status:'success',data:{account:{balance:s.balance},summary:{opening_balance:500000,received_from_head_office:0,expenses_deducted:500000-s.balance,closing_balance:s.balance},entries:s.entries,pagination:{page:1,pages:1,total:s.entries.length}}});
  if(path==='/v1/expenses'&&req.method==='GET'){
    let data=Object.values(s.records); const by_status=Object.fromEntries(statuses.map(status=>[status,{count:data.filter(e=>e.status===status).length,amount:data.filter(e=>e.status===status).reduce((a,e)=>a+e.amount.total,0)}]));
    if(url.searchParams.get('status'))data=data.filter(e=>e.status===url.searchParams.get('status'));
    return send(200,{status:'success',data,totals:{by_status},pagination:{page:1,pages:1,total:data.length}});
  }
  const city={_id:'city-1',name:'KOLKATA'};
  const product={line_id:'line-1',product:'product-1',product_name:'Chicken Biryani',quantity:2,unit_weight_kg:0.55,vendor:{_id:'vendor-1',name:'Restaurant'}};
  const order={_id:'order-1',orderid:'T2P-1790000101',side:'delivery',sides:['pickup','delivery'],vendor_city:city,products:[product]};
  if(path==='/v1/expenses/lookups/cities')return send(200,{status:'success',data:[city,{_id:'city-2',name:'DELHI'}]});
  if(path==='/v1/expenses/lookups/food-purchase-orders'||path==='/v1/expenses/lookups/orders')return send(200,{status:'success',data:[order,{...order,_id:'order-2',orderid:'T2P-1790000102'}]});
  if(path==='/v1/expenses/lookups/food-purchase-lines'){
    const ids=(url.searchParams.get('orders')||'').split(',').filter(Boolean);
    return send(200,{status:'success',data:{orders:ids.map(_id=>({_id})),vendor_city:'city-1',lines:[{...product,order_quantity:ids.length*2,orders:ids.map((id,i)=>({order:id,orderid:`T2P-179000010${i+1}`,quantity:2}))}]}});
  }
  if(path.endsWith('/default-distance'))return send(200,{status:'success',data:{km:12.7,source:'google_road',side:url.searchParams.get('side')||'delivery'}});
  if(path==='/v1/expenses/lookups/cancelled-orders')return send(200,{status:'success',data:[{...order,_id:'cancelled-1',status:'cancel',stage_label:'Picked up'}]});
  // Transport fixture only: validates the multipart envelope. It does not
  // model the production image/PDF processor or storage service.
  const uploadMatch=path.match(/^\/v1\/expenses\/([^/]+)\/documents$/);
  if(uploadMatch && req.method==='POST') {
    const record=s.records[uploadMatch[1]];
    if(!record)return fail(404,'Expense not found');
    if(!full(record).actions.upload)return fail(403,'Upload is not allowed');
    if(!/^multipart\/form-data;.*boundary=/.test(req.headers['content-type']||''))return fail(422,'Expected multipart files');
    return send(200,{status:'success',message:'Documents uploaded',data:full(record)});
  }
  const match=path.match(/^\/v1\/expenses\/([^/]+)(?:\/(submit|recall|cancel|approve))?$/);
  if(path==='/v1/expenses'&&req.method==='POST'||match&&req.method==='PATCH'){
    const old=match?s.records[match[1]]:null;
    if(match&&!old)return fail(404,'Expense not found');
    if(old&&body.version!=null&&old.version!==body.version)return fail(409,'Expense changed. Reload it.');
    if(old&&!['draft','rejected'].includes(old.status))return fail(409,'Expense cannot be edited');
    if(!old&&s.ids[body.client_request_id])return send(200,{status:'success',message:'This expense was already saved',data:full(s.records[s.ids[body.client_request_id]])});
    const category=old?.category||body.category,d={...body.details};let total=0;
    const errors=[];
    if(category==='PETROL'&&Number(d.litres)<=0)errors.push({field:'details.litres',message:'litres must be positive'});
    if(category==='FOOD_PURCHASE')d.items.forEach((item,i)=>(item.adjustments||[]).forEach((a,j)=>{if(!a.note||a.note.length<3)errors.push({field:`details.items[${i}].adjustments[${j}].note`,message:'A reason is required'});}));
    if(errors.length)return send(422,{status:'validation_error',message:'Please correct the highlighted fields',errors});
    if(category==='PETROL'){total=money(Number(d.rate_per_litre)*Number(d.litres));d.rate_per_litre=money(d.rate_per_litre);}
    if(category==='INTERCITY_LOGISTICS'){total=money(Number(d.rate_per_kg)*Number(d.weight_kg));d.rate_per_kg=money(d.rate_per_kg);}
    if(['MISC','TRAVEL'].includes(category)){total=money(d.amount);d.amount=total;}
    if(category==='FOOD_PURCHASE'){
      d.orders=d.orders||old?.details.orders||['order-1'];
      d.items=d.items.map(item=>{const order_quantity=d.orders.length*2,quantity=order_quantity+(item.adjustments||[]).reduce((a,e)=>a+Number(e.quantity),0),subtotal=money(Number(item.rate||0)*quantity);
        const discount=item.discount_type==='percent'?Math.round(subtotal*Number(item.discount_value||0)/100):money(item.discount_value),gst=Math.round((subtotal-discount)*0.05);
        return {...item,product_name:'Chicken Biryani',order_quantity,quantity,orders:d.orders.map(order=>({order,orderid:order,quantity:2})),rate:money(item.rate),discount_value:money(item.discount_value),subtotal,discount,gst,total:subtotal-discount+gst};});total=d.items.reduce((a,e)=>a+e.total,0);
    }
    if(category==='CANCELLED_ORDER'){d.items=d.items.map(i=>({...i,product_name:'Chicken Biryani',quantity:2,left:2-i.dispositions.reduce((a,e)=>a+Number(e.quantity),0)}));d.total_left=d.items.reduce((a,e)=>a+e.left,0);}
    const id=old?old._id:`expense-${++s.seq}`;
    const e={...old,_id:id,category,category_label:labels[categories.indexOf(category)],expense_no:old?.expense_no||`EX-2627-${s.seq}`,version:(old?.version||0)+1,
      status:old?.status||(body.submit&&category!=='CANCELLED_ORDER'?'submitted':'draft'),expense_date:body.expense_date||'2026-10-16',business_date:body.expense_date||'2026-10-16',
      notes:body.notes||'',details:d,amount:{subtotal:total,total},documents:[],review:{rejection_reason:''},order_refs:[],history:old?.history||[{action:'created',to_status:'draft',at:'2026-10-16',actor:{name:'Test user'}}]};
    s.records[id]=e;if(!old&&body.client_request_id)s.ids[body.client_request_id]=id;
    if(!old&&e.status==='submitted')ledger(e);await persist();return send(old?200:201,{status:'success',message:'Expense saved',data:full(e),balance_after:s.balance});
  }
  if(match){const e=s.records[match[1]],action=match[2];if(!e)return fail(404,'Expense not found');
    if(!action&&req.method==='GET')return send(200,{status:'success',data:full(e)});
    if(action&&req.method==='POST'){
      if(body.version!=null&&body.version!==e.version)return fail(409,'Expense changed. Reload it.');
      if(!full(e).actions[action])return fail(409,'Action is not allowed');
      if(action==='submit'){e.status='submitted';ledger(e);}
      if(action==='recall'||action==='cancel'){const previous=e.status;e.status=action==='recall'?'draft':'cancelled';if(previous==='submitted')ledger(e,true);}
      if(action==='approve')e.status='approved';e.version++;e.history.push({action,to_status:e.status,at:'2026-10-16',actor:{name:'Test user'}});
      await persist();return send(200,{status:'success',message:'Expense updated',data:full(e),balance_after:s.balance});
    }
  }
  return fail(501,'Not modeled in this local contract fixture');
}).listen(process.env.PORT||4901);
