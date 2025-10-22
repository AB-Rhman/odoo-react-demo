import React, {useEffect, useState} from 'react';

export default function App(){
  const [data, setData] = useState(null);

  useEffect(()=>{
    fetch('/react_demo/data', {credentials:'same-origin'})
      .then(r=>r.json())
      .then(d=>setData(d))
      .catch(e=>console.error(e));
  },[]);

  return (
    <div style={{padding:20}}>
      <h1>React inside Odoo</h1>
      {data ? (
        <div>
          <p><strong>Message:</strong> {data.message}</p>
          <p><strong>User:</strong> {data.user}</p>
        </div>
      ) : <p>Loading...</p>}
    </div>
  );
}