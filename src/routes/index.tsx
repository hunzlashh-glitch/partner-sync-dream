import { createFileRoute } from "@tanstack/react-router";
import { useEffect } from "react";

export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  useEffect(() => {
    window.location.replace("/crm.html");
  }, []);
  return (
    <div style={{ minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", background: "#0c0e12", color: "#98a0ad", fontFamily: "system-ui, sans-serif", fontSize: 13 }}>
      Loading CrestPoint CRM…
    </div>
  );
}
